# Messages<a name="EN-US_TOPIC_0000001103554544"></a>
-   [Introduction](#introductiona-nameintroductiona)
    -   [Content Introduction](#content-introductiona-namecontent-introductiona)
    -   [Architecture](#architecturea-namearchitecturea)
-   [Directory Structure](#directory-structurea-namedirectory-structurea)
-   [Repositories Involved](#repositories-involveda-namerepositories-involveda)

## Introduction<a name="Introduction"></a>
### Content Introduction<a name="Content-Introduction"></a>

The Messages App is a pre-installed system application in the OpenHarmony standard system, providing users with basic messaging capabilities. These include support for SMS notifications, message favorites, and Cell Broadcast Service (CBS), SMS conversation details and related operations, message reception, MMS, SMS, as well as open-source materials for the SMS application.

**Key Functions:**

1. **SMS/MMS Core Functions**: Supporting sending (including long SMS), receiving, forwarding, resending (for failed messages), and deleting (individual or batch) of SMS and MMS. It also enables group messaging for both SMS and MMS, with MMS supporting attachments such as photos, recordings, locations, contacts, slideshows, and more.
2. **Message Notification & Collection**: Displaying message notifications with options to mark as read, reply directly, or copy verification codes. Users can also collect important messages for easy access later.
3. **Conversation Management**: Providing a user-friendly message list with operations like left-swipe deletion, long-press multi-selection, and slide-to-select. Both the message list and detail pages display contact names and avatars for intuitive identification.
4. **Message Detail Operations**: Supporting multiple actions on message content, including copying text, selecting partial content, forwarding, saving (for MMS attachments), and deleting. Verification code messages feature a one-click copy button for convenience.
5. **Notification Message Handling**: Integrating notification messages into a dedicated list with functions such as marking all as read, deleting individually or in batches via long-press or slide selection.
6. **Supplementary Capabilities**: Including Cell Broadcast Service (CBS) support, delivery reports for messages, and dual-SIM card compatibility (switching between SIM 1 and SIM 2 for sending messages).

### Architecture<a name="Architecture"></a>
![](./figures/img.png)

## Directory Structure<a name="Directory-Structure"></a>

```
/Mms/
├── doc                                        # Documentation
├── entry
│   └── src
│       └── main
│           └── ets                            # ETS code directory
│               └── default                    # Business code directory
│                   ├── data                   # Custom data types
│                   ├── model                  # Database integration
│                   ├── pages                  # All pages
│                       ├── conversation       # Conversation detail page
│                       ├── conversationlist   # Message list page
│                       ├── index              # Initial page
│                       ├── infomsg            # Notification message list page
│                       ├── queryreport        # Report detail page
│                       └── settings           # Settings page
│                   ├── service                # Business logic
│                   ├── utils                  # Utility classes
│                   ├── views                  # Custom components
│                   └── app.ets                # Application lifecycle
│               └── StaticSubscriber           # Static event listener
│           ├── resources                      # Resource configuration file directory
│           └── config.json                    # Global configuration file
├── signs                                      # Signatures
└── LICENSE
```

## Repositories Involved<a name="Repositories-Involved"></a>

[**applications_contacts**]

[**telephony_sms_mms**]