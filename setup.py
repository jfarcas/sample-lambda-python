from setuptools import setup, find_packages

# Read version from __version__.py
exec(open('__version__.py').read())

setup(
    name="lambda-test-python",
    version=__version__,
    description="Sample Python Lambda function for testing deployment",
    author="Your Name",
    author_email="your.email@example.com",
    packages=find_packages(),
    python_requires=">=3.9",
    install_requires=[
        # Add your dependencies here
        # "requests>=2.28.0",
        # "boto3>=1.26.0",
    ],
    extras_require={
        "dev": [
            "pytest>=7.0.0",
            "pytest-cov>=4.0.0",
            "black>=22.0.0",
            "flake8>=5.0.0",
        ]
    },
    classifiers=[
        "Development Status :: 4 - Beta",
        "Intended Audience :: Developers",
        "License :: OSI Approved :: MIT License",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.9",
    ],
)
