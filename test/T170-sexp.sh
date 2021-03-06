#!/usr/bin/env bash
test_description="--format=sexp output"
. $(dirname "$0")/test-lib.sh || exit 1
. $NOTMUCH_SRCDIR/test/test-lib-emacs.sh || exit 1

test_begin_subtest "Show message: sexp"
add_message "[subject]=\"sexp-show-subject\"" "[date]=\"Sat, 01 Jan 2000 12:00:00 -0000\"" "[bcc]=\"test_suite+bcc@notmuchmail.org\"" "[reply-to]=\"test_suite+replyto@notmuchmail.org\"" "[body]=\"sexp-show-message\""
output=$(notmuch show --format=sexp "sexp-show-message")
test_expect_equal "$output" "((((:id \"${gen_msg_id}\" :match t :excluded nil :filename (\"${gen_msg_filename}\") :timestamp 946728000 :date_relative \"2000-01-01\" :tags (\"inbox\" \"unread\") :body ((:id 1 :content-type \"text/plain\" :content \"sexp-show-message\n\")) :crypto () :headers (:Subject \"sexp-show-subject\" :From \"Notmuch Test Suite <test_suite@notmuchmail.org>\" :To \"Notmuch Test Suite <test_suite@notmuchmail.org>\" :Bcc \"test_suite+bcc@notmuchmail.org\" :Reply-To \"test_suite+replyto@notmuchmail.org\" :Date \"Sat, 01 Jan 2000 12:00:00 +0000\")) ())))"

# This should be the same output as above.
test_begin_subtest "Show message: sexp --body=true"
output=$(notmuch show --format=sexp --body=true "sexp-show-message")
test_expect_equal "$output" "((((:id \"${gen_msg_id}\" :match t :excluded nil :filename (\"${gen_msg_filename}\") :timestamp 946728000 :date_relative \"2000-01-01\" :tags (\"inbox\" \"unread\") :body ((:id 1 :content-type \"text/plain\" :content \"sexp-show-message\n\")) :crypto () :headers (:Subject \"sexp-show-subject\" :From \"Notmuch Test Suite <test_suite@notmuchmail.org>\" :To \"Notmuch Test Suite <test_suite@notmuchmail.org>\" :Bcc \"test_suite+bcc@notmuchmail.org\" :Reply-To \"test_suite+replyto@notmuchmail.org\" :Date \"Sat, 01 Jan 2000 12:00:00 +0000\")) ())))"

test_begin_subtest "Show message: sexp --body=false"
output=$(notmuch show --format=sexp --body=false "sexp-show-message")
test_expect_equal "$output" "((((:id \"${gen_msg_id}\" :match t :excluded nil :filename (\"${gen_msg_filename}\") :timestamp 946728000 :date_relative \"2000-01-01\" :tags (\"inbox\" \"unread\") :crypto () :headers (:Subject \"sexp-show-subject\" :From \"Notmuch Test Suite <test_suite@notmuchmail.org>\" :To \"Notmuch Test Suite <test_suite@notmuchmail.org>\" :Bcc \"test_suite+bcc@notmuchmail.org\" :Reply-To \"test_suite+replyto@notmuchmail.org\" :Date \"Sat, 01 Jan 2000 12:00:00 +0000\")) ())))"

test_begin_subtest "Search message: sexp"
add_message "[subject]=\"sexp-search-subject\"" "[date]=\"Sat, 01 Jan 2000 12:00:00 -0000\"" "[body]=\"sexp-search-message\""
output=$(notmuch search --format=sexp "sexp-search-message" | notmuch_search_sanitize)
test_expect_equal "$output" "((:thread \"0000000000000002\" :timestamp 946728000 :date_relative \"2000-01-01\" :matched 1 :total 1 :authors \"Notmuch Test Suite\" :subject \"sexp-search-subject\" :query (\"id:$gen_msg_id\" nil) :tags (\"inbox\" \"unread\")))"

test_begin_subtest "Show message: sexp, utf-8"
add_message "[subject]=\"sexp-show-utf8-body-s??bj??ct\"" "[date]=\"Sat, 01 Jan 2000 12:00:00 -0000\"" "[body]=\"js??n-show-m??ssage\""
output=$(notmuch show --format=sexp "js??n-show-m??ssage")
test_expect_equal "$output" "((((:id \"${gen_msg_id}\" :match t :excluded nil :filename (\"${gen_msg_filename}\") :timestamp 946728000 :date_relative \"2000-01-01\" :tags (\"inbox\" \"unread\") :body ((:id 1 :content-type \"text/plain\" :content \"js??n-show-m??ssage\n\")) :crypto () :headers (:Subject \"sexp-show-utf8-body-s??bj??ct\" :From \"Notmuch Test Suite <test_suite@notmuchmail.org>\" :To \"Notmuch Test Suite <test_suite@notmuchmail.org>\" :Date \"Sat, 01 Jan 2000 12:00:00 +0000\")) ())))"

test_begin_subtest "Search message: sexp, utf-8"
add_message "[subject]=\"sexp-search-utf8-body-s??bj??ct\"" "[date]=\"Sat, 01 Jan 2000 12:00:00 -0000\"" "[body]=\"js??n-search-m??ssage\""
output=$(notmuch search --format=sexp "js??n-search-m??ssage" | notmuch_search_sanitize)
test_expect_equal "$output" "((:thread \"0000000000000004\" :timestamp 946728000 :date_relative \"2000-01-01\" :matched 1 :total 1 :authors \"Notmuch Test Suite\" :subject \"sexp-search-utf8-body-s??bj??ct\" :query (\"id:$gen_msg_id\" nil) :tags (\"inbox\" \"unread\")))"

test_begin_subtest "Show message: sexp, inline attachment filename"
subject='sexp-show-inline-attachment-filename'
id="sexp-show-inline-attachment-filename@notmuchmail.org"
emacs_fcc_message \
    "$subject" \
    'This is a test message with inline attachment with a filename' \
    "(mml-attach-file \"$NOTMUCH_SRCDIR/test/README\" nil nil \"inline\")
     (message-goto-eoh)
     (insert \"Message-ID: <$id>\n\")"
output=$(notmuch show --format=sexp "id:$id")
filename=$(notmuch search --output=files "id:$id")
# Get length of README after base64-encoding, minus additional newline.
attachment_length=$(( $(base64 $NOTMUCH_SRCDIR/test/README | wc -c) - 1 ))
test_expect_equal "$output" "((((:id \"$id\" :match t :excluded nil :filename (\"$filename\") :timestamp 946728000 :date_relative \"2000-01-01\" :tags (\"inbox\") :body ((:id 1 :content-type \"multipart/mixed\" :content ((:id 2 :content-type \"text/plain\" :content \"This is a test message with inline attachment with a filename\") (:id 3 :content-type \"application/octet-stream\" :content-disposition \"inline\" :filename \"README\" :content-transfer-encoding \"base64\" :content-length $attachment_length)))) :crypto () :headers (:Subject \"sexp-show-inline-attachment-filename\" :From \"Notmuch Test Suite <test_suite@notmuchmail.org>\" :To \"test_suite@notmuchmail.org\" :Date \"Sat, 01 Jan 2000 12:00:00 +0000\")) ())))"

test_done
