# Amp Container Development Environment

A complete containerized development environment with Amp CLI and essential development tools pre-installed.

## Quick Start

1. **Get your API key** from [ampcode.com/settings](https://ampcode.com/settings)

2. **Configure environment** - Edit `.env` file:
   ```bash
   AMP_API_KEY=your_actual_api_key_here
   GIT_USER_NAME=Your Name
   GIT_USER_EMAIL=your.email@example.com
   ```

3. **Build and run**:
   ```bash
   docker-compose build
   # Quick start - single instance
   ./scripts/startup/run-single-amp.sh
   
   # Or manually
   docker-compose run --rm amp-cli bash
   ```

## File Structure

```
amp-container-dev/
├── config/
│   └── amp-settings.json          # Amp CLI configuration
├── scripts/
│   ├── startup/                    # Host-side startup scripts
│   │   ├── run-single-amp.sh      # Quick single instance launcher
│   │   ├── run-multi-amp.sh       # Multiple instances in separate terminals
│   │   ├── run-single-amp-tmux.sh # Single instance with tmux
│   │   ├── run-multi-amp-tmux.sh  # Multiple instances in tmux panes
│   │   ├── run-batch-prompts-tmux.sh # Automated batch processing
│   │   ├── stop-multi-amp.sh      # Stop multiple instances
│   │   └── stop-multi-amp-tmux.sh # Stop tmux sessions
│   ├── entrypoint.sh             # Container initialization script
│   ├── amp-prompt.sh             # File-based prompt execution
│   ├── batch-prompts.sh          # Process multiple prompt files
│   └── colored-bash.sh           # Multi-instance colored terminals
├── workspace/                     # Your project files go here
├── .env                          # Environment variables
├── docker-compose.yml            # Container orchestration
├── Dockerfile                    # Container definition
└── README.md                     # This file
```

## Configuration Files

### `config/amp-settings.json`
Pre-configured Amp settings for optimal development:
- Auto-save enabled
- Confirmations disabled for faster workflow
- Aggressive mode for comprehensive suggestions
- Parallel execution for better performance

### `scripts/entrypoint.sh`
Handles container initialization:
- Git repository cloning (if `GIT_REPO` env var set)
- Git user configuration
- Amp authentication

### `.env`
Environment variables for customization:
- `AMP_API_KEY`: Your Amp API key (required)
- `GIT_USER_NAME`: Git username for commits
- `GIT_USER_EMAIL`: Git email for commits

## Usage Patterns

### Interactive Development
```bash
# Quick start - single instance
./scripts/startup/run-single-amp.sh

# Multiple instances in tmux panes
./scripts/startup/run-multi-amp-tmux.sh

# Automated batch processing
./scripts/startup/run-batch-prompts-tmux.sh 3

# Manual start
docker-compose run --rm amp-cli bash

# Inside container:
amp --version
echo "Help me write a Python function" | amp
```

### Direct Command Execution
```bash
# Code review
docker-compose run --rm amp-cli amp chat "Review this code for improvements"

# Add tests
docker-compose run --rm amp-cli amp chat "Add comprehensive tests for all functions"

# Refactoring
docker-compose run --rm amp-cli amp chat "Refactor this code following best practices"

# Documentation
docker-compose run --rm amp-cli amp chat "Generate documentation for this project"
```

### Working with Existing Projects

#### Option 1: Copy files to workspace
```bash
# Copy your project to the workspace directory
cp -r /path/to/your/project/* ./workspace/

# Then run container
docker-compose run --rm amp-cli bash
```

#### Option 2: Clone repository directly
```bash
# Set GIT_REPO environment variable
export GIT_REPO=https://github.com/username/repo.git
docker-compose run --rm amp-cli bash

# Or add to .env file:
# GIT_REPO=https://github.com/username/repo.git
```

## Common Amp Prompts

### Code Analysis
```bash
echo "Analyze this codebase and suggest improvements" | amp
echo "Find potential security vulnerabilities" | amp
echo "Identify performance bottlenecks" | amp
echo "Check for code duplication" | amp
```

### Development Tasks
```bash
echo "Add error handling to all functions" | amp
echo "Implement logging throughout the application" | amp
echo "Add input validation to API endpoints" | amp
echo "Create unit tests with 90% coverage" | amp
```

### Architecture & Design
```bash
echo "Suggest a better architecture for this project" | amp
echo "Refactor this monolith into microservices" | amp
echo "Add dependency injection pattern" | amp
echo "Implement clean architecture principles" | amp
```

### Documentation
```bash
echo "Generate API documentation" | amp
echo "Create README with setup instructions" | amp
echo "Add inline code comments" | amp
echo "Write technical specification document" | amp
```

### Debugging & Troubleshooting
```bash
echo "Debug this error and provide solution" | amp
echo "Optimize database queries" | amp
echo "Fix memory leaks in this application" | amp
echo "Resolve dependency conflicts" | amp
```

## Startup Scripts

**Host-side launcher scripts** (in `scripts/startup/`):

1. **`run-single-amp.sh`** - Quick launcher for single Amp instance
   ```bash
   ./scripts/startup/run-single-amp.sh
   ```

2. **`run-multi-amp.sh`** - Launch multiple instances in separate terminal windows
   ```bash
   ./scripts/startup/run-multi-amp.sh  # Creates 3 terminal windows
   ```

3. **`run-single-amp-tmux.sh`** - Single instance with tmux session management
   ```bash
   ./scripts/startup/run-single-amp-tmux.sh
   ```

4. **`run-multi-amp-tmux.sh`** - Multiple instances in tmux panes with colored backgrounds
   ```bash
   ./scripts/startup/run-multi-amp-tmux.sh  # Interactive: choose 1-10 instances
   ```

5. **`run-batch-prompts-tmux.sh`** - Automated batch processing with numbered prompts
   ```bash
   ./scripts/startup/run-batch-prompts-tmux.sh [num_instances]
   # Runs: amp < promptN.txt > outputN.txt in each container
   ```

6. **`stop-multi-amp.sh`** - Stop all running Amp containers
   ```bash
   ./scripts/startup/stop-multi-amp.sh
   ```

7. **`stop-multi-amp-tmux.sh`** - Stop tmux sessions
   ```bash
   ./scripts/startup/stop-multi-amp-tmux.sh
   ```

## Container Utility Scripts

**Built into containers** (in `scripts/`):

1. **`entrypoint.sh`** - Container initialization: Git setup, repo cloning, Amp authentication
2. **`amp-prompt.sh`** → `/usr/local/bin/amp-prompt` - Run Amp with file-based prompts: `amp-prompt /workspace/my-prompt.txt`
3. **`batch-prompts.sh`** → `/usr/local/bin/batch-prompts` - Process multiple prompt files from a directory sequentially
4. **`colored-bash.sh`** → `/usr/local/bin/colored-bash` - Multi-instance support with colored terminal backgrounds

## Build & Run Flow

**Build Process:**
1. `docker-compose build` → Uses Dockerfile
2. Installs Node.js 20 + dev tools (Git, Docker CLI, Python, build tools)
3. Installs Amp CLI + TypeScript/ESLint/Prettier/Jest globally
4. Creates `ampuser` (UID 1001) for security
5. Copies all scripts to `/usr/local/bin/` and makes executable
6. Sets up config directory and entrypoint

**Run Process:**
1. `docker-compose run --rm amp-cli bash` → Starts container
2. Executes entrypoint.sh: Auto-clones `$GIT_REPO`, configures Git user, sets Amp API key
3. Mounts `./workspace` → `/workspace` (persistent files)
4. Mounts `./config` → `/home/ampuser/.config/amp` (Amp settings)
5. Launches bash shell in `/workspace` with all tools available

## Pre-installed Tools

The container includes:
- **Amp CLI** - AI-powered development assistant
- **Node.js 20** - JavaScript runtime
- **TypeScript** - Type-safe JavaScript
- **ESLint** - Code linting
- **Prettier** - Code formatting
- **Jest** - Testing framework
- **Git** - Version control
- **Docker CLI** - Container management
- **Python 3** - Python runtime
- **Build tools** - make, g++, etc.

## Tips for Effective Usage

1. **Be specific** in your prompts for better results
2. **Use context** - Amp understands your entire project
3. **Iterate** - Refine requests based on initial results
4. **Combine tasks** - "Add tests AND improve error handling"
5. **Review changes** - Always verify Amp's suggestions before applying

## Troubleshooting

### Container won't start
- Check Docker is running
- Verify `.env` file has valid API key
- Run `docker-compose logs` for error details

### Amp authentication fails
- Verify API key is correct in `.env`
- Check network connectivity
- Ensure API key has proper permissions

### Permission issues
- Container runs as `ampuser` (UID 1001)
- Ensure workspace files are accessible
- Use `docker-compose exec amp-cli chown -R ampuser:ampuser /workspace` if needed

## Advanced Usage

### Custom configuration
Modify `config/amp-settings.json` to adjust Amp behavior:
- Increase `maxTokens` for larger projects
- Adjust `timeout` for slower operations
- Enable/disable `verboseLogging` as needed

### Multiple projects
Create separate directories for different projects:
```bash
mkdir project1 project2
# Copy this setup to each directory
# Modify workspace volume in docker-compose.yml as needed
```

### CI/CD Integration
Use in automated workflows:
```bash
# Example CI script
docker-compose run --rm amp-cli echo "Run all tests and generate coverage report" | amp
```
