# Example InSpec Profile

execute: `inspec exec combined --input-file combined/attributes/server.yml -t ssh://vaultadmin@10.0.2.5`

```
$ cat combined/attributes/server.yml
role: server
```

This example shows the implementation of an InSpec profile.
