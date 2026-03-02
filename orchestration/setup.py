from setuptools import find_packages, setup

setup(
    name="orchestration",
    version="1.0.0",
    packages=find_packages(),
    install_requires=[
        "dagster==1.12.15",
        "dagster-cloud==1.12.15",
        "dagster-dbt==0.28.15",
        "dbt-dremio==1.10.0",
    ],
    extras_require={
        "dev": [
            "dagster-webserver==1.12.15",
        ]
    },
)