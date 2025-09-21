# Evalora Backend

Evalora is a backend service built with FastAPI to help investors efficiently evaluate startups. It offers robust APIs for managing startup profiles, customizable evaluation criteria, automated scoring, and generating detailed reports.

## Features

- Startup profile management
- Customizable evaluation criteria
- Automated scoring algorithms
- Investor dashboard integration
- Secure authentication and authorization
- Comprehensive reporting services

## Tech Stack

- **Python** with **FastAPI**
- **MongoDB** for data storage
- **JWT** for authentication
- **RESTful API** design

## Getting Started

1. **Clone the repository:**
    ```bash
    cd server
    ```

2. **Install dependencies:**
    ```bash
    pip install -r requirements.txt
    ```

3. **Configure environment variables:**
    - Copy `.env.example` to `.env` and update values.

4. **Run the server:**
    ```bash
    uvicorn main:app --reload
    ```

## API Documentation

See [API Docs](./docs/API.md) for detailed endpoints and usage.

## Contributing

Contributions are welcome! Please open issues or submit pull requests.

## License

MIT License
