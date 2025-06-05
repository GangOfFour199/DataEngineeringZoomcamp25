``` bash
export JAVA_HOME="${HOME}/jdk-11.0.2"
export PATH="${JAVA_HOME}/bin:${PATH}"
```

``` bash
java --version
```

``` bash
export SPARK_HOME="${HOME}/spark-3.3.2-bin-hadoop3"
export PATH="${SPARK_HOME}/bin:${PATH}"
```

``` bash
spark-shell
```

```bash
export PYTHONPATH="${SPARK_HOME}/python/:$PYTHONPATH"
export PYTHONPATH="${SPARK_HOME}/python/lib/py4j-0.10.9.5-src.zip:$PYTHONPATH"
```

``` bash
which pyspark
```

``` bash
jupyter notebook
```
