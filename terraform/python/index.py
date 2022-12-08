import os
import boto3

""" AWS Clients """
ecsClient = boto3.client("ecs")
ecrClient = boto3.client("ecr")
pipeline = boto3.client("codepipeline")

subnet = os.environ["Subnet"]
subnet_alt = os.environ["SubnetAlt"]
security_group = os.environ["SecurityGroup"]


def update_services(cluster_name, revisions):
    services = {}
    try:
        response = ecsClient.describe_services(
            cluster=cluster_name,
            services=[
                f'{os.environ["App"]}_{os.environ["Env"]}_backend',
                f'{os.environ["App"]}_{os.environ["Env"]}_frontend',
            ],
        )
        for service in response["services"]:
            current_revision = service["taskDefinition"].split("/")[-1]
            task_family = current_revision.split(":")[0]

            if task_family in revisions.keys():
                revision = f"{task_family}:{revisions[task_family]}"
                response = ecsClient.update_service(
                    cluster=cluster_name,
                    service=service["serviceArn"],
                    taskDefinition=revision,
                )
                print(f'Updated service {response["service"]["serviceArn"]}:{revision}')
                services.update({response["service"]["serviceArn"]: revision})

    except Exception as e:
        print(str(e))

    return services


def update_task_definition(cluster_name, prefix):
    task_list = {}
    try:
        families_tags = {}
        for i in ["frontend", "backend", "console"]:
            response = ecsClient.list_task_definitions(familyPrefix=f"{prefix}-{i}")
            families = {x.split("/")[-1] for x in response["taskDefinitionArns"]}
            for j in families:
                name = j.split(":")[0]
                version = j.split(":")[1]
                if name in families_tags:
                    if version > families_tags[name]:
                        families_tags.update({name: version})
                else:
                    families_tags.update({name: version})

        for name, version in families_tags.items():
            current_task = ecsClient.describe_task_definition(
                taskDefinition=f"{name}:{version}"
            )
            task_definition = current_task["taskDefinition"]

            update_task = ecsClient.register_task_definition(
                family=name,
                taskRoleArn=task_definition["taskRoleArn"],
                executionRoleArn=task_definition["executionRoleArn"],
                networkMode=task_definition["networkMode"],
                containerDefinitions=task_definition["containerDefinitions"],
                volumes=task_definition["volumes"],
                placementConstraints=task_definition["placementConstraints"],
                requiresCompatibilities=task_definition["requiresCompatibilities"],
                cpu=task_definition["cpu"],
                memory=task_definition["memory"],
            )
            print(
                f'Register version {update_task["taskDefinition"]["taskDefinitionArn"]}'
            )

            task_list.update(
                {
                    update_task["taskDefinition"]["family"]: update_task[
                        "taskDefinition"
                    ]["revision"]
                }
            )

            ecsClient.deregister_task_definition(
                taskDefinition=task_definition["taskDefinitionArn"]
            )
            print(f'Deregister old version {task_definition["taskDefinitionArn"]}')

            if "console" in name:
                container = update_task["taskDefinition"]["containerDefinitions"][0]
                response = ecsClient.run_task(
                    cluster=cluster_name,
                    launchType="FARGATE",
                    taskDefinition=update_task["taskDefinition"]["taskDefinitionArn"],
                    networkConfiguration={
                        "awsvpcConfiguration": {
                            "subnets": [subnet, subnet_alt],
                            "securityGroups": [security_group],
                            "assignPublicIp": "DISABLED",
                        }
                    },
                    overrides={
                        "containerOverrides": [
                            {
                                "name": container["name"],
                                "command": ["python", "manage.py", "migrate"],
                            }
                        ]
                    },
                )
                print(f'Initiated task: {response["tasks"][0]["taskArn"]}')
    except Exception as e:
        print(str(e))

    return task_list


def parse_tags(image_ids):
    return set(i["imageTag"] for i in image_ids if "imageTag" in i)


def get_image_tags(prefix):
    tags = {}
    try:
        nginx = ecrClient.list_images(repositoryName=f"{prefix}-backend-nginx")
        backend = ecrClient.list_images(repositoryName=f"{prefix}-backend-django")
        frontend = ecrClient.list_images(repositoryName=f"{prefix}-frontend")
        tags = (
            parse_tags(nginx["imageIds"])
            & parse_tags(backend["imageIds"])
            & parse_tags(frontend["imageIds"])
        )
    except Exception as e:
        print(str(e))

    return tags


def lambda_handler(event, context):
    prefix = f'{os.environ["App"]}-{os.environ["Env"]}'
    cluster_name = f"{prefix}-cluster"
    release_tag = event["version"] if "version" in event else "latest"

    # Fetch all images tags and validate if current release is available in all repos
    tags = get_image_tags(prefix)
    if release_tag in tags:
        # Update task definition if trigger tag is available
        revisions = update_task_definition(cluster_name, prefix)

        # Update services to recent version
        update_services(cluster_name, revisions)

        return pipeline.put_job_success_result(jobId=event["CodePipeline.job"]["id"])
    raise pipeline.put_job_failure_result(jobId=event["CodePipeline.job"]["id"])


if __name__ == "__main__":
    lambda_handler(None, None)
