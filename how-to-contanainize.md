# Amp Containerization Cookbook

A comprehensive guide to running Amp CLI in a containerized development environment with all necessary tools pre-installed.

## Quick Start Summary

1. **Create project directory:**
   ```bash
   mkdir amp-container-dev && cd amp-container-dev
   mkdir -p config scripts workspace
   ```

2. **Get your Amp API key** from [ampcode.com/settings](https://ampcode.com/settings)

3. **Create the required files** (see complete file contents below)

4. **Configure your environment** - Edit `.env` with your actual API key

5. **Build and run:**
   ```bash
   docker-compose build
   docker-compose run --rm amp-cli bash
   ```

## Project Structure

```
amp-container-dev/
├── config/
│   └── amp-settings.json          # Amp CLI configuration
├── scripts/
│   └── entrypoint.sh             # Container initialization
├── workspace/                     # Your project files
├── .env                          # Environment variables
├── docker-compose.yml            # Container orchestration
├── Dockerfile                    # Container definition
└── README.md                     # Documentation
```

## Required Files to Create

### `config/amp-settings.json`

```json
{
  "amp.autoSave": true,
  "amp.confirmBeforeExecuting": false,
  "amp.maxTokens": 100000,
  "amp.aggressiveMode": true,
  "amp.autoApplyChanges": true,
  "amp.verboseLogging": true,
  "amp.timeout": 300000,
  "amp.retryAttempts": 3,
  "amp.parallelExecution": true
}
```

### `scripts/entrypoint.sh`

```bash
#!/bin/bash
set -e

if [ ! -d "/workspace/.git" ] && [ -n "$GIT_REPO" ]; then
    echo "Cloning repository: $GIT_REPO"
    git clone "$GIT_REPO" /workspace
    cd /workspace
fi

if [ -n "$GIT_USER_NAME" ]; then
    git config --global user.name "$GIT_USER_NAME"
fi

if [ -n "$GIT_USER_EMAIL" ]; then
    git config --global user.email "$GIT_USER_EMAIL"
fi

if [ -n "$AMP_API_KEY" ]; then
    echo "Authenticating with Amp..."
    export AMP_API_KEY="$AMP_API_KEY"
fi

exec "$@"
```

### `Dockerfile`

```dockerfile
FROM node:20-alpine

RUN apk add --no-cache \
    git openssh-client curl bash python3 py3-pip make g++ docker-cli jq

RUN npm install -g @sourcegraph/amp typescript eslint prettier jest

WORKDIR /workspace

RUN addgroup -g 1001 -S ampuser && \
    adduser -S ampuser -u 1001 -G ampuser && \
    mkdir -p /home/ampuser/.config/amp /home/ampuser/.ssh && \
    chown -R ampuser:ampuser /home/ampuser

COPY --chown=ampuser:ampuser config/amp-settings.json /home/ampuser/.config/amp/settings.json
COPY --chown=ampuser:ampuser scripts/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh

USER ampuser

ENV HOME=/home/ampuser
ENV AMP_CONFIG_DIR=/home/ampuser/.config/amp
ENV PATH="/home/ampuser/.local/bin:$PATH"

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["amp"]
```

### `docker-compose.yml`

```yaml
services:
  amp-cli:
    build: .
    container_name: amp-dev
    environment:
      - AMP_API_KEY=${AMP_API_KEY}
      - GIT_USER_NAME=${GIT_USER_NAME:-"Amp User"}
      - GIT_USER_EMAIL=${GIT_USER_EMAIL:-"user@example.com"}
      - AMP_AUTO_APPLY=true
      - AMP_SKIP_CONFIRMATIONS=true
      - AMP_AGGRESSIVE_MODE=true
    volumes:
      - ./workspace:/workspace
      - ./config:/home/ampuser/.config/amp
    working_dir: /workspace
    stdin_open: true
    tty: true
    networks:
      - amp-network

networks:
  amp-network:
    driver: bridge
```

### `.env`

```bash
# Replace with your actual API key from ampcode.com/settings
AMP_API_KEY=your_api_key_here
GIT_USER_NAME=Your Name
GIT_USER_EMAIL=your.email@example.com
```

## How to Run

### 1. Build the container
```bash
docker-compose build
```

### 2. Run interactively (recommended)
```bash
docker-compose run --rm amp-cli bash
```

### 3. Inside the container, test Amp
```bash
amp --version
echo "Hello, can you help me write a Python function?" | amp
```

### 4. Work with your code

**Option A: Copy existing project**
```bash
# Copy your project files to the workspace directory
cp -r /path/to/your/project/* ./workspace/
```

**Option B: Clone repository**
```bash
# Inside container
git clone https://github.com/user/repo.git .

# Or set GIT_REPO environment variable
export GIT_REPO=https://github.com/user/repo.git
docker-compose run --rm amp-cli bash
```

## Common Usage Patterns

### Direct Command Execution
```bash
# Code review
docker-compose run --rm amp-cli amp chat "Review this code for improvements"

# Add tests
docker-compose run --rm amp-cli amp chat "Add tests for all functions in this project"

# Refactoring
docker-compose run --rm amp-cli amp chat "Refactor this code following best practices"

# Documentation
docker-compose run --rm amp-cli amp chat "Generate comprehensive documentation"
```

### Interactive Development Session
```bash
# Start interactive session
docker-compose run --rm amp-cli bash

# Inside container - various Amp commands
echo "Analyze this codebase for security vulnerabilities" | amp
echo "Optimize performance of this application" | amp
echo "Add error handling to all API endpoints" | amp
echo "Implement comprehensive logging" | amp
```

## Pre-installed Tools

The container includes:
- **Amp CLI** - AI-powered development assistant
- **Node.js 20** - JavaScript runtime (required for Amp CLI)
- **TypeScript** - Type-safe JavaScript development
- **ESLint** - Code linting and style checking
- **Prettier** - Code formatting
- **Jest** - JavaScript testing framework
- **Git** - Version control
- **Docker CLI** - Container management
- **Python 3** - Python runtime and development
- **Build tools** - make, g++, pip for compiling native dependencies
- **jq** - JSON processing tool

## Key Features

✅ **Node.js 20+** - Required for Amp CLI compatibility  
✅ **Pre-configured settings** - Optimized for development workflow  
✅ **Security** - Runs as non-root user (`ampuser`)  
✅ **Volume mounting** - Persistent workspace and configuration  
✅ **Environment variables** - Easy customization via `.env`  
✅ **Git integration** - Automatic repository cloning and user setup  
✅ **Complete toolchain** - All essential development tools included  

## Important Notes

- **Node.js Version**: Uses Node.js 20 (required for Amp CLI v20+)
- **API Key**: Must be obtained from [ampcode.com/settings](https://ampcode.com/settings)
- **Security**: Container runs as `ampuser` (UID 1001) for security
- **Persistence**: Use `./workspace/` directory for persistent files
- **Configuration**: Amp settings are pre-configured for optimal development

## Troubleshooting

### Container Build Issues
```bash
# Clean build
docker-compose build --no-cache

# Check logs
docker-compose logs
```

### Amp Authentication Issues
```bash
# Verify API key in .env file
cat .env

# Test authentication inside container
docker-compose run --rm amp-cli bash
echo $AMP_API_KEY
amp --version
```

### Permission Issues
```bash
# Fix workspace permissions
docker-compose exec amp-cli chown -R ampuser:ampuser /workspace
```

## Advanced Usage

### Custom Configuration
Modify `config/amp-settings.json` to adjust Amp behavior:
- Increase `maxTokens` for larger projects
- Adjust `timeout` for complex operations
- Enable/disable `verboseLogging` as needed

### CI/CD Integration
```bash
# Example automated workflow
docker-compose run --rm amp-cli echo "Run all tests and generate coverage report" | amp
docker-compose run --rm amp-cli echo "Lint and format all code" | amp
```

The containerized environment provides a complete, reproducible development setup with Amp CLI and all essential tools, making it perfect for consistent development workflows across different machines and environments.
