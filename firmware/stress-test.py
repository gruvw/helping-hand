import requests
import time


TIMEOUT = 10

# target
url = "http://hh-0001.local/click?angle=121&channel=1&duration=100"


def start_clicking():
    count = 0
    print(f"🚀 Starting requests to {url}...")
    print("Press Ctrl+C to stop at any time.\n")

    while True:
        try:
            response = requests.post(url, timeout=10)
            count += 1

            if response.ok:
                print(f"Count: {count} | Success")
            else:
                print(f"Count: {count} | Server Error: {response.status_code}")

        # catches timeouts, connection resets, and DNS issues
        except requests.exceptions.RequestException as e:
            count += 1
            print(f"\nCount: {count} | Request Failed: {e}\n")

        time.sleep(0.1)


if __name__ == "__main__":
    start_clicking()
