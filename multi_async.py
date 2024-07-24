
import asyncio
import time


def getfilenames():
    return [f'{i}.txt' for i in range(10)]

async def readlines(filename):
    print(f'processing {filename}')
    return [f'line {i}'for i in range(10**7)]


async def main():
    t1 = time.perf_counter(), time.process_time()
    tasks = []
    for filename in getfilenames():
        print(f"{filename}")
        tasks.append(asyncio.create_task(readlines(filename)))

    total = 0
    jobs = await asyncio.gather(*tasks)
    for i in jobs:
        total += len(i)

    t2 = time.perf_counter(), time.process_time()
    print()
    print(f"Real time: {t2[0] - t1[0]:.2f} seconds")
    print(f"CPU time: {t2[1] - t1[1]:.2f} seconds")
    print(f"Total lines: {total:,}")
    print()

if __name__ == "__main__":
    asyncio.run(main())