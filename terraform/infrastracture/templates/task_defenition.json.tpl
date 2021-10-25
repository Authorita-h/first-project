[
    {
        "name": "${workspace}-service",
        "image": "${image_repository_path}:latest",
        "memory": 256,
        "essentials": true,
        "portMappings": [
            {
            "containerPort": 80,
            "hostPort": 80
            }
        ]
    }
]