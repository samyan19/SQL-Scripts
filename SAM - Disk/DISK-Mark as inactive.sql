/* http://serverfault.com/questions/276076/how-can-i-un-mark-a-partition-as-active */

1.) Start>Run..

2.) “CMD”

3.) “diskpart” to load up the utility

4.) “list disk” to list all the disks

5.) “Select disk X” where X is the desired disk

6.) “list partition” to list partitions on the selected disk

7.) “select partition X” where X is the desired partition that is currently marked active

8.) “inactive”
