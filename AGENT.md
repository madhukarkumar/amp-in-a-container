# AGENT.md - Amp Container Development Environment

## Commands

**Build & Run:**
- `docker-compose build` - Build the Amp container
- `./scripts/startup/run-single-amp.sh` - Quick launcher for single Amp instance
- `./scripts/startup/run-multi-amp-tmux.sh` - Multiple instances in tmux panes
- `./scripts/startup/run-batch-prompts-tmux.sh` - Automated batch processing
- `docker-compose run --rm amp-cli bash` - Manual interactive session

**Container Operations:**
- `docker-compose logs` - View container logs
- `docker-compose exec amp-cli bash` - Attach to running container
- `./scripts/startup/stop-multi-amp.sh` - Stop multiple instances

**Testing & Linting (within container):**
- `eslint .` - JavaScript/TypeScript linting
- `prettier --check .` - Code formatting check
- `jest` - Run JavaScript tests
- `amp --version` - Verify Amp CLI installation

## Architecture

**Container Environment:**
- Base: Node.js 20 Alpine Linux
- User: `ampuser` (UID 1001) for security
- Working directory: `/workspace`
- Pre-installed tools: Amp CLI, TypeScript, ESLint, Prettier, Jest, Git, Docker CLI, Python 3

**Directory Structure:**
- `config/` - Amp CLI settings (`amp-settings.json`)
- `scripts/` - Container initialization and utility scripts
- `workspace/` - Mounted volume for project files (persistent)

**Environment Variables:**
- `AMP_API_KEY` - Required Amp authentication
- `GIT_USER_NAME/EMAIL` - Git configuration
- `GIT_REPO` - Auto-clone repository on startup

## Code Style & Conventions

**Configuration:** Amp settings optimized for development workflow:
- Auto-save enabled, confirmations disabled
- Aggressive mode with parallel execution
- 100K token limit, 5-minute timeout
- Verbose logging for debugging

**File Management:** Use `./workspace/` for all persistent files
**Security:** Never commit API keys; use `.env` file for secrets
**Container Patterns:** Run as non-root user, mount volumes for persistence
