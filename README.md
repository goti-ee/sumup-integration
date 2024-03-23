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
