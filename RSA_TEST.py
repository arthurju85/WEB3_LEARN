"""
生成并保存 RSA 2048 位公私钥到 keys 目录。
"""

from pathlib import Path
from cryptography.hazmat.primitives.asymmetric import rsa  # pyright: ignore[reportMissingImports]
from cryptography.hazmat.primitives import serialization  # pyright: ignore[reportMissingImports]
from cryptography.hazmat.primitives import hashes  # pyright: ignore[reportMissingImports]
from cryptography.hazmat.primitives.asymmetric import padding  # pyright: ignore[reportMissingImports]
from cryptography.hazmat.backends import default_backend  # pyright: ignore[reportMissingImports]


def generate_and_save_keys() -> tuple[Path, Path]:
    """
    检测已有密钥；若不存在或损坏则生成并保存。
    """

    base_dir = Path(__file__).resolve().parent
    keys_dir = base_dir / "keys"
    keys_dir.mkdir(parents=True, exist_ok=True)

    private_path = keys_dir / "private_key.pem"
    public_path = keys_dir / "public_key.pem"

    # 已有则直接返回（确认可读取）
    if private_path.exists() and public_path.exists():
        try:
            serialization.load_pem_private_key(
                private_path.read_bytes(), password=None, backend=default_backend()
            )
            serialization.load_pem_public_key(
                public_path.read_bytes(), backend=default_backend()
            )
            print("检测到已有密钥，跳过重新生成。")
            return private_path, public_path
        except Exception:
            print("已有密钥文件无法读取，将重新生成。")

    private_key = rsa.generate_private_key(
        public_exponent=65537,
        key_size=2048,
        backend=default_backend(),
    )

    private_pem = private_key.private_bytes(
        encoding=serialization.Encoding.PEM,
        format=serialization.PrivateFormat.TraditionalOpenSSL,
        encryption_algorithm=serialization.NoEncryption(),
    )

    public_pem = private_key.public_key().public_bytes(
        encoding=serialization.Encoding.PEM,
        format=serialization.PublicFormat.SubjectPublicKeyInfo,
    )

    private_path.write_bytes(private_pem)
    public_path.write_bytes(public_pem)

    print("已生成新的密钥对。")
    return private_path, public_path


if __name__ == "__main__":
    priv, pub = generate_and_save_keys()
    print(f"私钥已保存到: {priv}")
    print(f"公钥已保存到: {pub}")

    # 示例：使用私钥对消息签名，并用公钥验证
    message = "arthur:nonce"
    data = message.encode("utf-8")

    private_key = serialization.load_pem_private_key(priv.read_bytes(), password=None, backend=default_backend())
    public_key = serialization.load_pem_public_key(pub.read_bytes(), backend=default_backend())

    signature = private_key.sign(
        data,
        padding.PSS(
            mgf=padding.MGF1(hashes.SHA256()),
            salt_length=padding.PSS.MAX_LENGTH,
        ),
        hashes.SHA256(),
    )

    print(f"签名（hex）: {signature.hex()}")

    public_key.verify(
        signature,
        data,
        padding.PSS(
            mgf=padding.MGF1(hashes.SHA256()),
            salt_length=padding.PSS.MAX_LENGTH,
        ),
        hashes.SHA256(),
    )
    print("验证成功")
