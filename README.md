# SumupIntegration

A simple service that syncs SumUp sales with external data storage (e.g. PostgresSQL) to allow future analysis.

Internally, it is used with [Metabase](https://www.metabase.com/) to visualize insights into sales.

## Data normalisations

This service also performs different data transformations to simplify analysis.

Available normalisation pipelines:

1. `EventDetector` - matches transactions to actual events based on the timestamp. It allows easy filtering
based on the event name which is easily understandable by the end user.
2. `SuperficialSaleRemoval` - SumUp doesn't allow having "free" items. This is inconvenient because we use SumUp for
inventory tracking. We set a minimal price for such items ("0.01") as a workaround. This pipeline detects such sales and
sets the price to 0.
3. `SaleTypeDetector` - we use sale types for internal analytics. It allows to clearly understand which syles are
revenue-generating and which are for internal consumption. This module uses a combination of category name and
description based detection logic.
4. `DescriptionNormalizer` - SumUp has a bug in their API that forces sales with multiple positions in it not to be
returned as separate products via API. Instead, the API returns them as a blob string "2 x Apple Juice, 5 x Candy".
This makes aggregations harder than they need to be. This module makes sure such transcations are normalized and split.

## Product REPL

To enter deployment's container, one needs to execute:
```shell
dokku enter sumup-integration web
```

To spin up REPL:
```shell
./bin/sumup_integration remote
```

Finally, to introduce all REPL helpers, write:
```shell
use SumupIntegration.Help
```
