import json
import sys
import requests
import time


def StrIsJson(str):
    try:
        json.loads(str)
        return True
    except ValueError as e:
        return False


def SendPostRequest(uri, request_body):
    try:
        headers = {}
        if StrIsJson(request_body):
            headers["Content-Type"] = "application/json"
        else:
            headers["Content-Type"] = "text/plain"

        response = requests.post(
            uri, headers=headers, data=request_body.encode("utf-8")
        )
        if response.status_code == 200:
            print("Post request sent successfully to", uri)
        else:
            print(
                "Failed to send post request to",
                uri,
                "Status code:",
                response.status_code,
            )
    except Exception as e:
        print("Error:", e)


if __name__ == "__main__":
    param_cnt = len(sys.argv) - 1
    if param_cnt < 3:
        raise SystemExit("param cnt={} too less".format(param_cnt))

    uri = sys.argv[1]
    request_body = sys.argv[2]
    sleep_sec = int(sys.argv[3])
    while True:
        SendPostRequest(uri, request_body)
        time.sleep(sleep_sec)
