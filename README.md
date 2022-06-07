# Nextflow `groupTuple` bug

A minimal reproducible example demonstrating a possible bug in `groupTuple`, which triggers a null pointer exception
under certain circumstances.

## Error messages

Console:

```text
Cannot invoke method add() on null object
```

Log file:

```text
java.lang.NullPointerException: Cannot invoke method add() on null object
```

Full stack trace (from log file):

```text
java.lang.NullPointerException: Cannot invoke method add() on null object
        at org.codehaus.groovy.runtime.NullObject.invokeMethod(NullObject.java:91)
        at org.codehaus.groovy.runtime.callsite.PogoMetaClassSite.call(PogoMetaClassSite.java:44)
        at org.codehaus.groovy.runtime.callsite.CallSiteArray.defaultCall(CallSiteArray.java:47)
        at org.codehaus.groovy.runtime.callsite.NullCallSite.call(NullCallSite.java:34)
        at org.codehaus.groovy.runtime.callsite.CallSiteArray.defaultCall(CallSiteArray.java:47)
        at java_util_List$add$9.call(Unknown Source)
        at nextflow.extension.GroupTupleOp.collect(GroupTupleOp.groovy:110)
        at java.base/jdk.internal.reflect.NativeMethodAccessorImpl.invoke0(Native Method)
        at java.base/jdk.internal.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:62)
        at java.base/jdk.internal.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
        at java.base/java.lang.reflect.Method.invoke(Method.java:566)
        at org.codehaus.groovy.reflection.CachedMethod.invoke(CachedMethod.java:107)
        at groovy.lang.MetaMethod.doMethodInvoke(MetaMethod.java:323)
        at groovy.lang.MetaClassImpl.invokeMethod(MetaClassImpl.java:1268)
        at groovy.lang.MetaClassImpl.invokeMethodClosure(MetaClassImpl.java:1048)
        at groovy.lang.MetaClassImpl.invokeMethod(MetaClassImpl.java:1142)
        at groovy.lang.MetaClassImpl.invokeMethod(MetaClassImpl.java:1035)
        at groovy.lang.Closure.call(Closure.java:412)
        at groovy.lang.Closure.call(Closure.java:428)
        at groovy.lang.Closure$call$0.call(Unknown Source)
        at org.codehaus.groovy.runtime.callsite.CallSiteArray.defaultCall(CallSiteArray.java:47)
        at org.codehaus.groovy.runtime.callsite.PogoMetaClassSite.call(PogoMetaClassSite.java:53)
        at org.codehaus.groovy.runtime.callsite.AbstractCallSite.call(AbstractCallSite.java:139)
        at nextflow.extension.DataflowHelper$_subscribeImpl_closure2.doCall(DataflowHelper.groovy:285)
        at jdk.internal.reflect.GeneratedMethodAccessor82.invoke(Unknown Source)
        at java.base/jdk.internal.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
        at java.base/java.lang.reflect.Method.invoke(Method.java:566)
        at org.codehaus.groovy.reflection.CachedMethod.invoke(CachedMethod.java:107)
        at groovy.lang.MetaMethod.doMethodInvoke(MetaMethod.java:323)
        at org.codehaus.groovy.runtime.metaclass.ClosureMetaClass.invokeMethod(ClosureMetaClass.java:274)
        at groovy.lang.MetaClassImpl.invokeMethod(MetaClassImpl.java:1035)
        at groovy.lang.Closure.call(Closure.java:412)
        at groovyx.gpars.dataflow.operator.DataflowOperatorActor.startTask(DataflowOperatorActor.java:120)
        at groovyx.gpars.dataflow.operator.DataflowOperatorActor.onMessage(DataflowOperatorActor.java:108)
        at groovyx.gpars.actor.impl.SDAClosure$1.call(SDAClosure.java:43)
        at groovyx.gpars.actor.AbstractLoopingActor.runEnhancedWithoutRepliesOnMessages(AbstractLoopingActor.java:293)
        at groovyx.gpars.actor.AbstractLoopingActor.access$400(AbstractLoopingActor.java:30)
        at groovyx.gpars.actor.AbstractLoopingActor$1.handleMessage(AbstractLoopingActor.java:93)
        at groovyx.gpars.util.AsyncMessagingCore.run(AsyncMessagingCore.java:132)
        at java.base/java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1128)
        at java.base/java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:628)
        at java.base/java.lang.Thread.run(Thread.java:834)
```

## Environment

```text
Nextflow version 22.04.0 build 5697
GNU bash, version 5.1.16(1)-release (x86_64-apple-darwin19.6.0)
openjdk 11.0.9.1 2020-11-04 LTS
OpenJDK Runtime Environment Zulu11.43+55-CA (build 11.0.9.1+1-LTS)
OpenJDK 64-Bit Server VM Zulu11.43+55-CA (build 11.0.9.1+1-LTS, mixed mode)
macOS Catalina 10.15.7 (19H1824)
```

## Commands to reproduce

macOS (local machine)

```bash
conda create -p $(pwd -P)/conda_env/ -y -c conda-forge -c bioconda -c defaults 'nextflow ==22.04.0' && conda activate conda_env/
nextflow run main.nf
```

Ubuntu 20.04.3 LTS (Docker via macOS host)

```bash
cat <<EOF > script.sh
mamba install -y -c conda-forge -c bioconda -c defaults 'nextflow ==22.04.0'
nextflow run main.nf
EOF
docker run -ti -v $(pwd -P)/:/working/ -w /working/ condaforge/mambaforge:4.11.0-2 /usr/bin/env bash ./script.sh
```
