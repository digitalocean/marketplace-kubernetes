# Vijil Dome

Vijil Dome is an opensource guardrail system that can assist in protecting your AI agents

## Deploying Vijil Dome

Vijil Dome requires a few secrets in order to be deployed. In order to deploy it. It requires API keys so that it can make LLM requests that assist in protecting your agent. You should overwrite the existing `secrets.yml` file in this directory with your own API keys:

```bash
secrets:
    app:
        DOME_API_KEY: xxxxxxxxxxxxxxxxxxxxxxxxxx
        OPENAI_API_KEY: xxxxxxxxxxxxxxxxxxxxxxxxxx
        TOGETHER_API_KEY: xxxxxxxxxxxxxxxxxxxxxxxxxx
```

- `DOME_API_KEY`: Is some API key you'll need to set that helps authenticate your requests
- `OPENAI_API_KEY`: Is your key that you use to make OpenAI API requests with
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
curl "123.45.67.898/input_detection?api_key=abc-123&input_str=hello"
curl "123.45.67.898/output_detection?api_key=abc-123&output_str=hello"

curl "123.45.67.898/async_input_detection?api_key=abc-123&input_str=hello"
curl "123.45.67.898/async_output_detection?api_key=abc-123&output_str=hello"
```

For more information on how Vijil Dome works, you can view Vijil's [docs](https://docs.vijil.ai/dome/intro.html) about the subject.
