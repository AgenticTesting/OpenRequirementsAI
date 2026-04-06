# nopCommerce System Compliance and Security
# Feature Area: PCI Compliance, Audit Logging, Data Retention, Race Conditions
# DeFOSPAM NFR Requirements | Business Goal: Ensure legal compliance and fraud prevention

@compliance @critical @regression
Feature: System Compliance and Security
  As a system administrator and compliance officer
  I want to ensure the system maintains audit logs, protects sensitive data, and prevents race conditions
  So that the business remains compliant with regulations and maintains customer trust

  Background:
    Given audit logging is enabled and operational
    And PCI-DSS compliance controls are enforced
    And data retention policies are configured
    And database locking mechanisms are in place

  @audit-logging @critical @regression
  Scenario: Immutable Audit Logging of Sensitive Actions
    Given a customer takes a sensitive action
    When the customer changes their password
      | action | timestamp           | user              | oldValue   | newValue   |
      | PASSWORD_CHANGE | 2026-04-04T14:32:15Z | alice@example.com | [HASHED]   | [HASHED]   |
    Then an immutable audit log record is created with:
      | field             | value                 |
      | Action type       | PASSWORD_CHANGE       |
      | Timestamp         | 2026-04-04T14:32:15Z |
      | User identifier   | alice@example.com     |
      | User ID           | 12345                 |
      | IP address        | 203.0.113.42          |
      | Old value         | [HASHED]              |
      | New value         | [HASHED]              |

  @audit-logging @regression
  Scenario Outline: Audit Log Sensitive Actions
    Given a user performs sensitive actions
    When actions occur:
      | actionType           | timestamp              | user                 |
      | <actionType>         | <timestamp>            | <user>               |
    Then immutable audit logs are created for:
      | action               |
      | PASSWORD_CHANGE      |
      | ADDRESS_UPDATE       |
      | DISCOUNT_APPLIED     |
      | INVENTORY_ADJUSTMENT |
      | ADMIN_LOGIN          |
      | ADMIN_LOGOUT         |
      | REFUND_PROCESSED     |

  @audit-logging @regression
  Scenario: Audit Log Storage and Retention
    Given audit logs are being recorded
    When logs are stored
    Then logs are stored in:
      | property              |
      | Append-only table     |
      | Read-only permissions |
      | No DELETE/UPDATE allowed |
    And logs are retained per policy:
      | requirement                      |
      | Minimum 7 years for compliance   |
      | Immutable cloud storage backup   |
      | Digital signature for integrity  |
      | Regular export to external audit |

  @audit-logging @regression
  Scenario: Audit Log Access and Search
    Given audit logs exist in the system
    When an administrator searches audit logs
    Then logs can be filtered and searched by:
      | criterion  |
      | Action type |
      | User       |
      | Date range |
      | Order ID   |
      | Customer   |
    And logs are exported for compliance purposes
    And exports are signed and timestamped

  @pci-dss @critical @regression
  Scenario: Payment Card Data Security - No Plaintext Storage
    Given a customer enters credit card information
    When payment data is submitted
    Then the system ensures:
      | requirement                      |
      | Full card number NOT stored in DB |
      | CVV transmitted to processor only |
      | Card data NOT in application logs |
      | Card data NOT in error messages   |
      | Payment token stored instead      |
      | Sensitive data redacted in logs   |

  @pci-dss @critical @regression
  Scenario: Payment Data Encryption in Transit
    Given customer is transmitting payment data
    When card information is sent from browser to server
    Then transmission is protected by:
      | security_measure          |
      | HTTPS/TLS 1.2 minimum     |
      | Strong cipher suites      |
      | Certificate validation    |
      | No mixed content (HTTP)   |
      | Secure payment tokenization |

  @pci-dss @regression
  Scenario: Payment Data Encryption at Rest
    Given payment tokens are stored in database
    When payment data is persisted
    Then data is protected by:
      | protection_measure        |
      | AES-256 encryption        |
      | Key management service    |
      | Database encryption       |
      | Secure key rotation       |

  @pci-dss @regression
  Scenario: PCI-DSS Compliance Assessment
    Given the system processes credit card payments
    When compliance audit is conducted
    Then the system is assessed for:
      | assessment_area           |
      | Payment processor selection (Level 1 certified) |
      | Data protection controls  |
      | Access controls           |
      | Security monitoring       |
      | Incident response plan    |
      | Network segmentation      |
      | Annual audit by QSA       |
    And compliance status is documented

  @data-retention @critical @regression
  Scenario: Data Retention Policy Implementation
    Given the system stores customer personal data
    When data retention evaluation runs
    Then the system enforces retention policies:
      | data_type           | retention_period            |
      | Active customer     | Indefinite (while active)   |
      | Inactive customer   | 24 months inactivity + purge |
      | Order history       | 7 years (anonymized)        |
      | Audit logs          | 7 years minimum             |
      | Payment tokens      | Per processor policy        |
      | Customer email      | Until deletion request      |

  @data-retention @regression
  Scenario: Automatic Purging of Inactive Customer Data
    Given a customer has been inactive for 24+ months
    When the data purging scheduled job executes
    Then customer data is purged:
      | data_purged             |
      | Account record          |
      | Personal identifiers    |
      | Email address           |
      | Phone number            |
      | Billing/shipping address |
      | Payment method tokens   |
    And order history is anonymized:
      | action_taken            |
      | Customer ID set to NULL |
      | Email removed/masked    |
      | Address cleared         |

  @data-retention @regression
  Scenario: Right to Be Forgotten - Customer Deletion Request
    Given a customer submits a deletion request (GDPR right to be forgotten)
    When the deletion request is processed
    Then the system immediately purges:
      | data_purged             |
      | Account and profile     |
      | Personal identifiers    |
      | Contact information     |
      | Payment methods         |
      | Browsing history        |
    And retains anonymized records for accounting/compliance
    And deletion is logged immutably

  @data-retention @regression
  Scenario: Data Retention Audit Trail
    Given data purging and retention actions occur
    When a compliance audit is conducted
    Then audit trail shows:
      | audit_item                     |
      | Number of customers purged     |
      | Date/time of purge             |
      | Data categories purged         |
      | Deletion authorization         |
      | Confirmation of data destruction |

  @race-condition @critical @regression
  Scenario: Prevent Race Condition in Stock Reservation
    Given two customers simultaneously attempt to purchase last inventory item
    When both customers reach order confirmation at nearly same time
      | customer | confirmTime     |
      | A        | 11:23:45.000    |
      | B        | 11:23:45.500    |
    Then database-level locking prevents overselling:
      | behavior                        |
      | Customer A acquires lock        |
      | Customer B waits for lock       |
      | Customer A order succeeds       |
      | Inventory decremented to 0      |
      | Lock released                   |
      | Customer B stock check fails    |
      | Customer B order rejected       |
    And overselling is prevented
    And inventory remains accurate

  @race-condition @regression
  Scenario: Locking Mechanism Prevents Data Corruption
    Given concurrent updates to shared resources
    When multiple requests attempt simultaneous modifications
    Then the system uses:
      | mechanism                      |
      | Database row-level locking     |
      | SELECT FOR UPDATE statements   |
      | Transaction isolation levels   |
      | Optimistic locking (versioning)|
      | Inventory reservation system   |
    And data consistency is maintained
    And no duplicate reservations occur

  @race-condition @regression
  Scenario: Concurrent Order Processing Without Overselling
    Given a product has 3 units in stock
    When 5 customers attempt to order 3 units each simultaneously
    Then the system correctly processes:
      | outcome                        |
      | First customer order accepted  |
      | Inventory reduced to 0         |
      | Remaining 4 orders rejected    |
      | Accurate inventory state       |
      | No negative inventory          |

  @security @encryption @regression
  Scenario: Sensitive Data Encryption End-to-End
    Given sensitive customer data is collected
    When data is transmitted, stored, and accessed
    Then encryption is applied at:
      | layer                          |
      | In transit (HTTPS/TLS)         |
      | At rest (AES-256)              |
      | Field-level (for PII)          |
      | Backup encryption              |
    And encryption keys are securely managed
    And key rotation is scheduled

  @security @access-control @regression
  Scenario: Role-Based Access Control for Sensitive Functions
    Given different user roles exist (Customer, Admin, Operator)
    When users attempt to access sensitive functions
    Then access is controlled:
      | role        | canViewAuditLogs | canProcessRefund | canAdjustInventory |
      | Customer    | No               | No               | No                 |
      | Admin       | Yes              | Yes              | Yes                |
      | Operator    | Limited          | Yes              | Yes                |
    And unauthorized access is logged and blocked
