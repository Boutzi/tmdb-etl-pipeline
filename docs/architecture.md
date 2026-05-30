tmdb-etl-pipeline/
│
├── dags/                        # Les DAGs Airflow (orchestration)
│   └── tmdb_pipeline_dag.py
│
├── etl/                         # Le cœur de ta pipeline
│   ├── extract/                 # Tout ce qui touche à l'API TMDB
│   │   └── tmdb_client.py
│   ├── transform/               # Nettoyage et structuration des données
│   │   └── movies_transformer.py
│   └── load/                    # Chargement vers Snowflake
│       └── snowflake_loader.py
│
├── glue_jobs/                   # Scripts pour AWS Glue (semaine 2)
│   └── process_movies.py
│
├── dbt/                         # Modèles dbt (semaine 4)
│   ├── models/
│   └── dbt_project.yml
│
├── tests/                       # Tes tests unitaires
│   └── test_transformer.py
│
├── docs/                        # Documentation complémentaire
│   └── architecture.md
│
├── .env.example                 # Template des variables d'environnement
├── .gitignore
├── docker-compose.yml           # Pour lancer Airflow en local
├── requirements.txt             # Dépendances Python
└── README.md