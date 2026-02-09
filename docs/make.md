# Make

## Available commands

### Setup

Build the container.

Command: `make setup`


### Destroy

Stop the container and remove volumes.

Command: `make destroy`


### Up

Start the container.

Command: `make up`

Options:

| Option   | Required | Default |
|----------|----------|---------|
| RDP_PORT | yes      | 3389    |
| USERNAME | yes      | kodi    |


### Down

Stop the container.

Command: `make down`


### Shell

Attach an interactive shell to the container.

Command: `make shell`


### Test

Run all tests.

Command: `make test`
