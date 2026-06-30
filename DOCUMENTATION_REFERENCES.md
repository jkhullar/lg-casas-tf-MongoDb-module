# MongoDB Atlas Documentation References

This document contains all official documentation sources used to create this module.

---

## Official MongoDB Atlas Documentation

### Getting Started

**MongoDB Atlas Official Website**
- Main site: https://www.mongodb.com/cloud/atlas
- Sign up: https://www.mongodb.com/cloud/atlas/register
- Login: https://cloud.mongodb.com/

**MongoDB Atlas Documentation**
- Complete documentation: https://www.mongodb.com/docs/atlas/
- Getting Started Guide: https://www.mongodb.com/docs/atlas/getting-started/
- Quickstart Tutorial: https://www.mongodb.com/docs/atlas/tutorial/deploy-free-tier-cluster/

---

## Cluster Configuration

### Instance Sizes & Pricing

**Instance Size Documentation**
- GCP Instance Sizes: https://www.mongodb.com/docs/atlas/reference/google-gcp/
- AWS Instance Sizes: https://www.mongodb.com/docs/atlas/reference/amazon-aws/
- Azure Instance Sizes: https://www.mongodb.com/docs/atlas/reference/microsoft-azure/

**Pricing**
- Pricing Calculator: https://www.mongodb.com/pricing
- Cost Breakdown: https://www.mongodb.com/cloud/atlas/pricing
- Free Tier Limits: https://www.mongodb.com/docs/atlas/reference/free-shared-limitations/

### Regions & Availability Zones

**GCP Regions**
- GCP Region Mapping: https://www.mongodb.com/docs/atlas/reference/google-gcp/#std-label-google-gcp
- Region Availability: https://www.mongodb.com/docs/atlas/reference/google-gcp/#available-regions

**AWS Regions**
- AWS Region Mapping: https://www.mongodb.com/docs/atlas/reference/amazon-aws/#available-regions

**Azure Regions**
- Azure Region Mapping: https://www.mongodb.com/docs/atlas/reference/microsoft-azure/#available-regions

---

## Cluster Types & Architecture

**Cluster Configuration**
- Cluster Types: https://www.mongodb.com/docs/atlas/cluster-config/
- Replica Sets: https://www.mongodb.com/docs/atlas/cluster-config/multi-cloud-distribution/
- Sharded Clusters: https://www.mongodb.com/docs/atlas/cluster-config/sharded-cluster/

**High Availability**
- Replica Set Elections: https://www.mongodb.com/docs/manual/core/replica-set-elections/
- Automatic Failover: https://www.mongodb.com/docs/atlas/cluster-config/high-availability/

---

## Backup & Recovery

**Cloud Backup**
- Backup Overview: https://www.mongodb.com/docs/atlas/backup/cloud-backup/overview/
- Backup Snapshots: https://www.mongodb.com/docs/atlas/backup/cloud-backup/snapshot-schedule/
- Point-in-Time Restore: https://www.mongodb.com/docs/atlas/backup/cloud-backup/point-in-time-restores/
- Restore from Backup: https://www.mongodb.com/docs/atlas/backup/cloud-backup/restore/

**Backup Pricing**
- Backup Costs: https://www.mongodb.com/docs/atlas/billing/backup-costs/

---

## Security

### Encryption

**Encryption at Rest**
- Overview: https://www.mongodb.com/docs/atlas/security/encryption-at-rest/
- Cloud Provider Encryption: https://www.mongodb.com/docs/atlas/security/encryption-at-rest/#cloud-provider-encryption
- Customer Key Management (CMEK): https://www.mongodb.com/docs/atlas/security/encryption-at-rest/#customer-key-management

**Encryption in Transit**
- TLS/SSL Configuration: https://www.mongodb.com/docs/atlas/security/encryption-in-transit/

### Network Access

**IP Access List**
- IP Whitelisting: https://www.mongodb.com/docs/atlas/security/ip-access-list/
- Private Endpoints: https://www.mongodb.com/docs/atlas/security-private-endpoint/

### Authentication & Authorization

**Database Users**
- Create Database User: https://www.mongodb.com/docs/atlas/security-add-mongodb-users/
- Database User Roles: https://www.mongodb.com/docs/atlas/security-add-mongodb-roles/

**API Keys**
- Programmatic API Keys: https://www.mongodb.com/docs/atlas/configure-api-access/
- API Key Permissions: https://www.mongodb.com/docs/atlas/reference/api/apiKeys/

---

## Connection & Integration

### Connection Strings

**Connection String Formats**
- Standard Connection String: https://www.mongodb.com/docs/manual/reference/connection-string/
- SRV Connection String: https://www.mongodb.com/docs/manual/reference/connection-string/#std-label-connections-dns-seedlist
- Connection String Options: https://www.mongodb.com/docs/manual/reference/connection-string/#connection-string-options

**Driver Documentation**
- Node.js Driver: https://www.mongodb.com/docs/drivers/node/current/
- Python Driver (PyMongo): https://www.mongodb.com/docs/drivers/python/
- Java Driver: https://www.mongodb.com/docs/drivers/java/sync/current/
- Go Driver: https://www.mongodb.com/docs/drivers/go/current/
- C# Driver: https://www.mongodb.com/docs/drivers/csharp/current/

---

## Terraform Provider Documentation

### MongoDB Atlas Terraform Provider

**Official Terraform Registry**
- Provider Page: https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs
- Provider Configuration: https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs#authentication

**Resources**
- **mongodbatlas_advanced_cluster** (RECOMMENDED - Modern): https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/advanced_cluster
- mongodbatlas_cluster (DEPRECATED): https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/cluster
- mongodbatlas_database_user: https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/database_user
- mongodbatlas_project_ip_access_list: https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/project_ip_access_list

**Data Sources**
- mongodbatlas_advanced_cluster: https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/data-sources/advanced_cluster
- mongodbatlas_advanced_clusters: https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/data-sources/advanced_clusters
- mongodbatlas_cluster (deprecated): https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/data-sources/cluster

**GitHub Repository**
- Source Code: https://github.com/mongodb/terraform-provider-mongodbatlas
- Examples: https://github.com/mongodb/terraform-provider-mongodbatlas/tree/master/examples

---

## MongoDB Database Documentation

### Core Concepts

**MongoDB Manual**
- Complete Manual: https://www.mongodb.com/docs/manual/
- Introduction: https://www.mongodb.com/docs/manual/introduction/
- CRUD Operations: https://www.mongodb.com/docs/manual/crud/

**Database Design**
- Data Modeling: https://www.mongodb.com/docs/manual/core/data-modeling-introduction/
- Schema Design: https://www.mongodb.com/docs/manual/data-modeling/
- Indexes: https://www.mongodb.com/docs/manual/indexes/

### MongoDB Versions

**Version Information**
- MongoDB 7.0 Release Notes: https://www.mongodb.com/docs/manual/release-notes/7.0/
- MongoDB 8.0 Release Notes: https://www.mongodb.com/docs/manual/release-notes/8.0/
- Version Compatibility: https://www.mongodb.com/docs/manual/release-notes/

---

## Monitoring & Performance

### Atlas Monitoring

**Metrics & Alerts**
- Real-time Metrics: https://www.mongodb.com/docs/atlas/tutorial/view-cluster-metrics/
- Alert Configuration: https://www.mongodb.com/docs/atlas/configure-alerts/
- Performance Advisor: https://www.mongodb.com/docs/atlas/performance-advisor/

**Query Performance**
- Query Profiler: https://www.mongodb.com/docs/atlas/query-profiler/
- Slow Query Logs: https://www.mongodb.com/docs/atlas/tutorial/profile-database/
- Index Recommendations: https://www.mongodb.com/docs/atlas/performance-advisor/#index-recommendations

---

## Operations & Maintenance

### Scaling

**Cluster Scaling**
- Scale Cluster: https://www.mongodb.com/docs/atlas/scale-cluster/
- Auto-scaling: https://www.mongodb.com/docs/atlas/cluster-autoscaling/
- Storage Auto-scaling: https://www.mongodb.com/docs/atlas/cluster-autoscaling/#storage-autoscaling

### Upgrades & Maintenance

**Version Upgrades**
- Upgrade MongoDB Version: https://www.mongodb.com/docs/atlas/tutorial/upgrade-mongodb-version/
- Maintenance Windows: https://www.mongodb.com/docs/atlas/tutorial/set-maintenance-window/

---

## Migration & Import/Export

### Data Migration

**Migration Tools**
- Live Migration: https://www.mongodb.com/docs/atlas/import/live-import/
- mongodump/mongorestore: https://www.mongodb.com/docs/database-tools/mongodump/
- mongoexport/mongoimport: https://www.mongodb.com/docs/database-tools/mongoexport/

**Migration Guides**
- Migrate to Atlas: https://www.mongodb.com/docs/atlas/import/
- Self-Managed to Atlas: https://www.mongodb.com/docs/atlas/import/live-import/

---

## Compliance & Certifications

### Security Compliance

**Compliance Documentation**
- Security Overview: https://www.mongodb.com/cloud/trust
- SOC 2 Type II: https://www.mongodb.com/cloud/trust/compliance/soc-2
- GDPR Compliance: https://www.mongodb.com/cloud/trust/gdpr
- HIPAA Compliance: https://www.mongodb.com/cloud/trust/compliance/hipaa

**Service Level Agreement (SLA)**
- Atlas SLA: https://www.mongodb.com/cloud/atlas/sla

---

## API Documentation

### MongoDB Atlas API

**REST API**
- API Reference: https://www.mongodb.com/docs/atlas/reference/api-resources-spec/
- API Authentication: https://www.mongodb.com/docs/atlas/configure-api-access/
- API Endpoints: https://www.mongodb.com/docs/atlas/api/

**Common API Operations**
- Clusters API: https://www.mongodb.com/docs/atlas/reference/api/clusters/
- Database Users API: https://www.mongodb.com/docs/atlas/reference/api/database-users/
- Projects API: https://www.mongodb.com/docs/atlas/reference/api/projects/

---

## Best Practices

### Design & Architecture

**Best Practices Guides**
- Atlas Best Practices: https://www.mongodb.com/docs/atlas/best-practices/
- Connection String Best Practices: https://www.mongodb.com/docs/atlas/troubleshoot-connection/
- Schema Design Best Practices: https://www.mongodb.com/developer/products/mongodb/schema-design-best-practices/

### Performance Optimization

**Performance Guides**
- Performance Best Practices: https://www.mongodb.com/docs/manual/administration/analyzing-mongodb-performance/
- Index Best Practices: https://www.mongodb.com/docs/manual/applications/indexes/
- Query Optimization: https://www.mongodb.com/docs/manual/core/query-optimization/

---

## Tutorials & Learning Resources

### Official Tutorials

**MongoDB University**
- Free Online Courses: https://learn.mongodb.com/
- MongoDB for Developers: https://learn.mongodb.com/learning-paths/mongodb-nodejs-developer-path
- MongoDB for DBAs: https://learn.mongodb.com/learning-paths/mongodb-administrator-path

**Hands-On Tutorials**
- Getting Started with Atlas: https://www.mongodb.com/docs/atlas/tutorial/
- Build Your First Cluster: https://www.mongodb.com/docs/atlas/tutorial/deploy-free-tier-cluster/

### Developer Resources

**MongoDB Developer Hub**
- Developer Center: https://www.mongodb.com/developer/
- Code Examples: https://www.mongodb.com/developer/code-examples/
- Blog & Articles: https://www.mongodb.com/developer/languages/

---

## Tools & Utilities

### MongoDB Tools

**Database Tools**
- MongoDB Database Tools: https://www.mongodb.com/docs/database-tools/
- MongoDB Shell (mongosh): https://www.mongodb.com/docs/mongodb-shell/
- MongoDB Compass (GUI): https://www.mongodb.com/products/compass

**Command Line Tools**
- Atlas CLI: https://www.mongodb.com/docs/atlas/cli/stable/
- mongosh Documentation: https://www.mongodb.com/docs/mongodb-shell/

---

## Support & Community

### Official Support

**Support Channels**
- MongoDB Support: https://support.mongodb.com/
- Submit a Case: https://support.mongodb.com/welcome
- Support Plans: https://www.mongodb.com/support

**Community Resources**
- MongoDB Community Forums: https://www.mongodb.com/community/forums/
- Stack Overflow: https://stackoverflow.com/questions/tagged/mongodb
- MongoDB Community Edition: https://www.mongodb.com/try/download/community

---

## Billing & Cost Management

### Cost Documentation

**Billing Information**
- Billing Overview: https://www.mongodb.com/docs/atlas/billing/
- View Invoices: https://www.mongodb.com/docs/atlas/billing/view-invoices/
- Payment Methods: https://www.mongodb.com/docs/atlas/billing/payment-methods/

**Cost Optimization**
- Cost Explorer: https://www.mongodb.com/docs/atlas/billing/cost-explorer/
- Cost Alerts: https://www.mongodb.com/docs/atlas/billing/cost-alerts/

---

## Additional Resources

### MongoDB Atlas Features

**Advanced Features**
- Serverless Instances: https://www.mongodb.com/docs/atlas/serverless-instances/
- Global Clusters: https://www.mongodb.com/docs/atlas/global-clusters/
- Full-Text Search: https://www.mongodb.com/docs/atlas/atlas-search/
- Charts & Visualization: https://www.mongodb.com/docs/charts/

### Integration Guides

**Third-Party Integrations**
- AWS Integration: https://www.mongodb.com/docs/atlas/reference/amazon-aws/
- GCP Integration: https://www.mongodb.com/docs/atlas/reference/google-gcp/
- Azure Integration: https://www.mongodb.com/docs/atlas/reference/microsoft-azure/
- Kubernetes Integration: https://www.mongodb.com/docs/kubernetes-operator/

---

## Quick Reference Links

### Most Important Links

**Essential Documentation:**
```
1. MongoDB Atlas Docs:        https://www.mongodb.com/docs/atlas/
2. Terraform Provider:         https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs
3. Pricing Calculator:         https://www.mongodb.com/pricing
4. GCP Instance Sizes:         https://www.mongodb.com/docs/atlas/reference/google-gcp/
5. Connection Strings:         https://www.mongodb.com/docs/manual/reference/connection-string/
6. Security Best Practices:    https://www.mongodb.com/docs/atlas/best-practices/
```

**Getting Help:**
```
1. MongoDB Support:            https://support.mongodb.com/
2. Community Forums:           https://www.mongodb.com/community/forums/
3. Stack Overflow:             https://stackoverflow.com/questions/tagged/mongodb-atlas
4. GitHub Issues (Provider):   https://github.com/mongodb/terraform-provider-mongodbatlas/issues
```

**Learning Resources:**
```
1. MongoDB University:         https://learn.mongodb.com/
2. Developer Hub:              https://www.mongodb.com/developer/
3. YouTube Channel:            https://www.youtube.com/c/MongoDBofficial
4. Webinars:                   https://www.mongodb.com/presentations
```

---

## How to Use These References

### For Understanding Concepts

**Start Here:**
1. MongoDB Atlas Docs Overview: https://www.mongodb.com/docs/atlas/
2. Getting Started Guide: https://www.mongodb.com/docs/atlas/getting-started/
3. MongoDB Manual (Core Concepts): https://www.mongodb.com/docs/manual/introduction/

### For Implementation

**Terraform-Specific:**
1. Terraform Provider Docs: https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs
2. Cluster Resource: https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/cluster
3. Provider Examples: https://github.com/mongodb/terraform-provider-mongodbatlas/tree/master/examples

### For Operations

**Day-to-Day Operations:**
1. Monitoring & Alerts: https://www.mongodb.com/docs/atlas/tutorial/view-cluster-metrics/
2. Backup & Restore: https://www.mongodb.com/docs/atlas/backup/cloud-backup/overview/
3. Scaling: https://www.mongodb.com/docs/atlas/scale-cluster/

### For Troubleshooting

**When Things Go Wrong:**
1. Troubleshooting Connection: https://www.mongodb.com/docs/atlas/troubleshoot-connection/
2. Performance Issues: https://www.mongodb.com/docs/atlas/performance-advisor/
3. Support Portal: https://support.mongodb.com/

---

## Version-Specific Documentation

### This Module Uses:

**Terraform Provider Version: ~> 1.21**
- Provider 1.21 Docs: https://registry.terraform.io/providers/mongodb/mongodbatlas/1.21.0/docs
- Provider Changelog: https://github.com/mongodb/terraform-provider-mongodbatlas/blob/master/CHANGELOG.md

**MongoDB Version: 7.0 (default)**
- MongoDB 7.0 Manual: https://www.mongodb.com/docs/v7.0/
- 7.0 Release Notes: https://www.mongodb.com/docs/manual/release-notes/7.0/

---

## Glossary of Terms

**MongoDB Atlas Terminology:**
- **Cluster**: A group of MongoDB servers
- **Project**: Container for clusters and settings
- **Organization**: Top-level container for projects
- **Replica Set**: Multiple copies of data for redundancy
- **Shard**: Partition of data in sharded clusters
- **M-size**: Instance size (M0, M10, M20, etc.)
- **Oplog**: Operations log for replication
- **Atlas**: MongoDB's cloud database platform

**Reference:** https://www.mongodb.com/docs/atlas/reference/glossary/

---

## Document Updates

**Last Updated:** June 2026

**MongoDB Atlas Product Updates:**
- Product Announcements: https://www.mongodb.com/blog/channel/product
- What's New: https://www.mongodb.com/docs/atlas/reference/whats-new/

**Terraform Provider Updates:**
- Provider Releases: https://github.com/mongodb/terraform-provider-mongodbatlas/releases
- Migration Guides: https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/guides/migration-guide

---

## Need More Help?

**Contact Information:**
- MongoDB Sales: https://www.mongodb.com/contact
- Technical Support: https://support.mongodb.com/
- Community Slack: https://community.mongodb.com/

**Emergency Support:**
- Critical Issues (Paid Support): Open case at https://support.mongodb.com/
- Community Help: https://www.mongodb.com/community/forums/

---

**Note:** All links were verified as of June 2026. MongoDB may update URLs over time. If a link is broken, search for the topic on https://www.mongodb.com/docs/
