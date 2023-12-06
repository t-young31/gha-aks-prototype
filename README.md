# gha-aks-prototype
Deployment of [ARC](https://github.com/actions/actions-runner-controller) on
Azure kubernetes (AKS)

> [!WARNING]
> Not production ready

## Usage
0. Create a `.env` file from `.env.sample`
1. Login to Azure and deploy with
```bash
make login
make deploy
```
