from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives.asymmetric import rsa, ec
from cryptography.hazmat.backends import default_backend

def main():
    with open('cosign.pub', 'rb') as f:
        key = serialization.load_pem_public_key(f.read(), backend=default_backend())

    if isinstance(key, rsa.RSAPublicKey):
        public_numbers = key.public_numbers()
        print("RSA key")
        print(f"Modulus size: {key.key_size} bits")
        print(f"Public exponent: {public_numbers.public_exponent}")
        print(f"Modulus (first 20 hex digits): {hex(public_numbers.n)[:40]}...")
    elif isinstance(key, ec.EllipticCurvePublicKey):
        curve = key.curve
        print("EC key")
        print(f"Curve: {curve.name}")
        print(f"Key size: {curve.key_size} bits")
        public_numbers = key.public_numbers()
        print(f"Public point: x={public_numbers.x}, y={public_numbers.y}")
    else:
        print("Other/Unsupported")



if __name__ == "__main__":
    main()
