Feature: IMAP reply draft keeps its thread

  Background:
    Given there exists an account with username "[user:user1]" and password "password"
    And there exists an account with username "[user:user2]" and password "password"
    Then it succeeds
    When bridge starts
    And the user logs in with username "[user:user1]" and password "password"
    And user "[user:user1]" finishes syncing
    And user "[user:user1]" connects and authenticates SMTP client "1"
    And user "[user:user1]" connects and authenticates IMAP client "1"
    Then it succeeds

  Scenario: A reply draft appended over IMAP is linked to the message it answers
    When SMTP client "1" sends the following message from "[user:user1]@[domain]" to "[user:user2]@[domain]":
      """
      From: Bridge Test <[user:user1]@[domain]>
      To: Internal Bridge <[user:user2]@[domain]>
      Subject: Please Reply
      Message-ID: <something@protonmail.ch>

      hello

      """
    Then it succeeds
    When the user logs in with username "[user:user2]" and password "password"
    And user "[user:user2]" connects and authenticates IMAP client "2"
    And user "[user:user2]" finishes syncing
    Then IMAP client "2" eventually sees the following messages in "INBOX":
      | from                  | subject      | message-id                |
      | [user:user1]@[domain] | Please Reply | <something@protonmail.ch> |
    When IMAP client "2" appends the following message to "Drafts":
      """
      From: Internal Bridge <[user:user2]@[domain]>
      To: Bridge Test <[user:user1]@[domain]>
      Date: 01 Jan 1980 00:00:00 +0000
      Subject: Re: Please Reply
      In-Reply-To: <something@protonmail.ch>
      References: <something@protonmail.ch>

      Heya

      """
    Then it succeeds
    And IMAP client "2" eventually sees the following messages in "Drafts":
      | subject         | in-reply-to               | references                |
      | Re: Please Reply | <something@protonmail.ch> | <something@protonmail.ch> |
