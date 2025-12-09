import hashlib
import time


def mine(prefix: str, difficulty: int) -> None:
    """Brute-force a nonce so that sha256(prefix + nonce) has leading zeros."""
    target = "0" * difficulty
    nonce = 0
    start = time.perf_counter()

    while True:
        payload = f"{prefix}{nonce}".encode()
        digest = hashlib.sha256(payload).hexdigest()
        if digest.startswith(target):
            elapsed = time.perf_counter() - start
            print(f"nonce={nonce}")
            print(f"hash={digest}")
            print(f"elapsed={elapsed:.4f}s")
            return
        nonce += 1


if __name__ == "__main__":
    mine("arthur", 4)
    mine("arthur", 5)