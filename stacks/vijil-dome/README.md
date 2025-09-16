# Vijil Dome

Vijil Dome is an opensource guardrail system that can assist in protecting your AI agents

## Deploying Vijil Dome

Vijil Dome requires a few secrets in order to be deployed. In order to deploy it. It requires API keys so that it can make LLM requests that assist in protecting your agent. You should overwrite the existing `secrets.yml` file in this directory with your own API keys:

```bash
secrets:
    app:
        DOME_API_KEY: xxx
        OPENAI_API_KEY: xxx
        TOGETHER_API_KEY: xxx
```

- `DOME_API_KEY`: Is some API key you'll need to set that helps authenticate your requests.
- `OPENAI_API_KEY`: Is an optional key that you use to make OpenAI API requests with.
- `TOGETHER_API_KEY`: Is an optional key that is used for Together models. It's used in a few of the guardrails that Vijil Dome provides.

## Testing your Vijil Dome deployment

You should be able to see everything deployed by this helm chart doing the following:
```bash
NAME                                   READY   STATUS    RESTARTS   AGE
pod/vijil-dome-dome-559955f4d6-zvnj8   1/1     Running   0          3h4m

NAME                      TYPE           CLUSTER-IP      EXTERNAL-IP     PORT(S)        AGE
service/vijil-dome-dome   LoadBalancer   10.123.45.678   123.45.67.898   80:31809/TCP   3h4m

NAME                              READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/vijil-dome-dome   1/1     1            1           3h4m

NAME                                         DESIRED   CURRENT   READY   AGE
replicaset.apps/vijil-dome-dome-559955f4d6   1         1         1       3h4m
```

In order to test your deployment, you can use the `EXTERNAL-IP` of the created service:
```bash
$ curl "123.45.67.898/input_detection?api_key=abc-123&input_str=hello"
$ curl "123.45.67.898/output_detection?api_key=abc-123&output_str=hello"

$ curl "123.45.67.898/async_input_detection?api_key=abc-123&input_str=hello"
$ curl "123.45.67.898/async_output_detection?api_key=abc-123&output_str=hello"
```

An example of how to modify Vijil Dome's configuration. For more information look at Vijil's Dome [documentation](https://docs.vijil.ai/dome/config.html) about the subject:
```bash
$ curl -XPATCH "123.45.67.898/config?api_key=xxx" \
-H "Content-Type: application/json" \
-d '{
  "input-guards": ["prompt-injection", "input-toxicity"],
  "output-guards": ["output-toxicity"],
  "input-early-exit": false,
  "prompt-injection": {
    "type": "security",
    "early-exit": false,
    "methods": ["prompt-injection-deberta-v3-base", "security-llm"],
    "security-llm": {
      "model_name": "gpt-4o"
    }
  },
  "input-toxicity": {
    "type": "moderation",
    "methods": ["moderations-oai-api"]
  },
  "output-toxicity": {
    "type": "moderation",
    "methods": ["moderation-prompt-engineering"]
  }
}'
```

For more information on how Vijil Dome works, you can view Vijil's [documentation](https://docs.vijil.ai/dome/intro.html) about the subject.
