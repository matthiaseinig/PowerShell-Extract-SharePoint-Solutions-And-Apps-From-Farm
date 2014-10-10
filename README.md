Extract All SharePoint Solutions and Apps from a SharePoint Farm
================================================================

When executed by a SharePoint farm admin on a server of a SharePoint 2010/2013 farm, this script downloads all
- Farm solutions (full trust code)
- Sandboxed solutions (form every site which is accessible)
- SharePoint Apps (from every web where an instance can be found)

As Sandboxed Solutions and App can be deployed in different version on different locations, this scripts retrieves the exact instance for a site/web and stores them locally in a folder named after the location.

Hence, if you have deployed the solution/app to many sites you might get a lot of duplicates.
This is intentinoal because the reason for this script is to audit your SharePoint customizations and see what, in which version is deployed where.

The audit is done with the help of the [SharePoint Code Analysis Framework (SPCAF)](http://www.spcaf.com/)

**For more information read the blog series**

* [SharePoint health check (1): Auditing the SharePoint farm](http://www.spcaf.com/blog/sharepoint-health-check-1-auditing-the-sharepoint-farm/)
* [SharePoint health check (2): Extracting Customizations](http://www.spcaf.com/blog/sharepoint-health-check-2-extracting-customizations/)
* [SharePoint health check (3): Auditing Customizations](http://www.spcaf.com/blog/sharepoint-health-check-3-auditing-customizations/)
