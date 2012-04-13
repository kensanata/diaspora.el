;;; diaspora-contacts.el --- 
;; 
;; Filename: diaspora-contacts.el
;; Description: 
;; Author: Christian
;; Maintainer: 
;; Created: mié abr 11 10:52:26 2012 (-0300)
;; Version: 
;; Last-Updated: 
;;           By: 
;;     Update #: 0
;; URL: 
;; Keywords: 
;; Compatibility: 
;; 
;; Features that might be required by this library:
;;
;;   None
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;;; Commentary: 
;; 
;; 
;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;;; Change Log:
;; 
;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 3, or
;; (at your option) any later version.
;; 
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.
;; 
;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth
;; Floor, Boston, MA 02110-1301, USA.
;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;;; Code:

(require 'json)
(require 'diaspora-urls)
(require 'diaspora-mode)
(require 'diaspora-stream)

(defcustom diaspora-contact-url
  "contacts"
  "This is the rest of the URL for getting the contact. The first part is usually taken from `diaspora-pod' variable.

See `diaspora-url' and `diaspora-url-json'."
  :type 'string
  :group 'diaspora-url
  )

(defconst diaspora-contact-buffer-name "*Diaspora Contacts*"
  "This is the name of the contact buffer.")

(defun diaspora-get-all-contacts ()
  "Retrieve the contact list and print it in a buffer called `diaspora-contact-buffer-name'."
  (interactive)
  (let ((inhibit-read-only t)	
	(contact-buffer (get-buffer-create diaspora-contact-buffer-name))
	)
    (with-current-buffer contact-buffer
      (diaspora-mode)
      (delete-region (point-min) (point-max))      
      )
    (diaspora-contacts-get-contacts contact-buffer)
    (switch-to-buffer contact-buffer)
    )
  )


(defun diaspora-contacts-show (json-parsed-contact)
  "Print a contact in the current buffer according to the JSON parsed element.

JSON-PARSED-CONTACT is a parsed part of the JSON readed by `json-read' that corresponds to the contact. Usually is a list of const."
  (let ((url (diaspora-url (cdr (assoc 'url json-parsed-contact))))
	(handle (cdr (assoc 'handle json-parsed-contact))) ;; Usually is the diaspora address (name@joindiaspora.com for example)
	(avatar (cdr (assoc 'avatar json-parsed-contact)))
	(name (cdr (assoc 'name json-parsed-contact)))
	(guid (cdr (assoc 'guid json-parsed-contact)))
	(id (cdr (assoc 'id json-parsed-contact)))
	)
    (insert (concat
	     (propertize 
	      "          ====================          \n"
	      'diaspora-message-separator t)))
    (insert (format "![%s](%s)" name avatar) "\n")
    (insert (propertize
	     (format "%s (%s):" name handle) 
	     'diaspora-is-user-name t)
	    "\n")
    (insert (format "[%s](%s)" url url) "\n")
    (insert (format "GUID: %s" guid) "\n")
    (insert (format "ID: %s" id) "\n")    
    )
  )

(defun diaspora-contacts-insert-finale (contacts-amount)
  "Insert at the end more information regarded to the contacts list."
    (insert (concat
	     (propertize 
	      "          ====================          \n"
	      'diaspora-message-separator t)))
    (insert (concat
	     (propertize 
	      "          ====================          \n"
	      'diaspora-message-separator t)))
    (insert (format "Amount of Contacts Listed: %s" contacts-amount))
    )
	    
(defun diaspora-contacts-parse-json-and-insert (buffer-from buffer-to)
  "Parse a JSON text in a buffer(BUFFER-FROM) and print the result contacts in another buffer(BUFFER-TO)

BUFFER-FROM has a JSON text as fetched from the contact's URL(without HTTP headers, there must be just the JSON text!).

BUFFER-FROM is the buffer where to take the JSON text.
BUFFER-TO is the buffer where to print the contacts."
  (with-current-buffer buffer-from
    (goto-char (point-min))
    (let* ((json-elts (json-read))
	   (le (length json-elts))
	   )
      (with-current-buffer buffer-to
	(dotimes (i le)	  	  
	  (diaspora-contacts-show (aref json-elts i))
	  )
	(diaspora-contacts-insert-finale le)
	)
      )
    )
  )

(defun diaspora-contacts-get-contacts (buffer-to) 
  "Retrieve contacts from D* and write it down into a buffer(BUFFER-TO) in a formated way.

Use `diaspora-contact-url' for getting the URL where to find JSON information.

Get any information necessary as well(like username, password and authenticity token)."
  (diaspora-ask)
  (diaspora-get-authenticity-token-if-necessary)
  (with-current-buffer (diaspora-get-url (diaspora-url-json diaspora-contact-url))
    (diaspora-delete-http-header)
    (diaspora-contacts-parse-json-and-insert (current-buffer) buffer-to)
    )
  )

(defun diaspora-get-stream-by-username (username)
  "Get the stream using the username. Username is the name used for login of the contact.

The `diaspora-username-url' functions help me finding the apropiate URL."
  
  (diaspora-get-stream-by-name (diaspora-username-name username))
  )

(provide 'diaspora-contacts)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; diaspora-contacts.el ends here