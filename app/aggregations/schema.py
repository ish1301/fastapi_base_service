from pydantic import BaseModel


class NetworkEventBase(BaseModel):
    ts: str
    uid: str
    id_orig_h: str
    id_orig_p: str
    id_resp_h: str
    id_resp_p: str
    proto: str
    service: str
    duration: str
    orig_bytes: str
    resp_bytes: str
    conn_state: str
    local_orig: str
    local_resp: str
    missed_bytes: str
    history: str
    orig_pkts: str
    orig_ip_bytes: str
    resp_pkts: str
    resp_ip_bytes: str
    tunnel_parents: str
    label: str
    detailed_label: str
    time: str


class NetworkEventCreate(NetworkEventBase):
    pass
