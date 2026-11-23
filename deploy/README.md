# Cloud deployment

The repository contains two different deployables:

- **GitHub Pages:** the documentation site only, published by `.github/workflows/docs-pages.yml`.
- **Cloud container:** the full DeepSeek Harness web application, built from `Dockerfile` and started by `deploy/start-web.sh`.

GitHub Pages cannot run the Node.js server, shell tools, native sandbox, or AI provider calls required by the full application.

## Required runtime settings

Set these environment variables in the cloud service:

```text
PORT=3080
PUBLIC_URL=https://your-app.example/
TRUSTED_HOSTS=your-app.example
```

`PUBLIC_URL` is the browser-facing HTTPS URL. `TRUSTED_HOSTS` must contain the hostname users will open. Never commit provider API keys; configure them as encrypted cloud secrets.

The container listens on the cloud-provided `PORT`, disables browser auto-opening, and binds to the container's private IP because Harness intentionally rejects `0.0.0.0`.

## Provider-neutral container contract

Build and run locally:

```sh
docker build -t deepseek-harness-cloud .
docker run --rm -p 3080:3080 \
  -e PUBLIC_URL=http://localhost:3080/ \
  -e TRUSTED_HOSTS=localhost \
  deepseek-harness-cloud
```

For production, put the container behind HTTPS ingress and keep `PUBLIC_URL` and `TRUSTED_HOSTS` aligned with the public hostname. Forward WebSocket upgrades and preserve the browser-facing `Host` header.
