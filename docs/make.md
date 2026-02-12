# Make

## Available commands

### Setup

Build the container and create the `.env` file.

Command: `make setup`


### Destroy

Stop the container and remove volumes.

Command: `make destroy`


### Up

Start the container.

Command: `make up`

Options:

| Option           | Default |
|------------------|---------|
| FORWARD_RDP_PORT | 3389    |
| USERNAME         | kodi    |


### Down

Stop the container.

Command: `make down`


### Shell

Attach an interactive shell to the container.

Command: `make shell`


### Test

Run all tests.

Command: `make test`
