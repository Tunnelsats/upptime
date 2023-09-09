---
name: Scheduled Maintenance
about: This logs scheduled maintenance windows in a fixed template
title: "[Scheduled Maintenance] "
labels: maintenance
assignees: ''

---

<!--
start: 2021-02-24T13:00:00+00:00
end: 2021-02-24T14:00:00+00:00
expectedDown/expectedDegraded: us1.tunnelsats.com,sg1.tunnelsats.com,de1.tunnelsats.com,de2.tunnelsats.com,de3.tunnelsats.com,br1.tunnelsats.com,au1.tunnelsats.com,tunnelsats.com
-->

### Remove the below blurb before logging
The start and end keys are mandatory and should contain an ISO datetime with the start and ending time for the scheduled maintenance respectively.

If you expect that an endpoint will go down during this time, you can add it to expectedDown and Upptime will not open an issue if it goes down within this time period. Similarly, you can add expectedDegraded if you expect degraded performance. Both these keys should have comma-separated list of slugs.

Upptime will automatically close the issue when the end time happens, and it shows both currently ongoing and past scheduled maintenance events on the static website.
