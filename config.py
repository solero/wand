"""
Server bind
-----------
Here place the address and port you
would like dash to run on.
ADDRESS : str
    Address to bind to.
PORT : int
    Port to listen on.
"""
ADDRESS = '0.0.0.0'
PORT = 3000

"""
PostgreSQL credentials
----------------------
Here place the PostgreSQL credentials
where your Houdini database is located.
"""
POSTGRES_HOST = 'db'
POSTGRES_NAME = 'postgres'
POSTGRES_USER = 'postgres'
POSTGRES_PASSWORD = 'postgres'


"""
Google reCAPTCHA
----------------
GCAPTCHA_URL : str
    Google captcha verify URL. Normally you do not need to
    modify this.
GSECRET_KEY : str
    Your reCAPTCHA secret key obtained from Google.
    
.. Google reCAPTCHA registration:
    https://www.google.com/recaptcha/admin/create
"""
GCAPTCHA_URL = 'https://www.google.com/recaptcha/api/siteverify'
GSECRET_KEY = ''

"""
Player usernames
----------------
USERNAME_FORCE_CASE : bool
    Force capitalized username no matter what user has
    submitted.
    
    ex:
        BASIL -> Basil
APPROVE_USERNAME : bool
    Approves username automatically so they do not have
    to be approved by an administrator.
"""
USERNAME_FORCE_CASE = True
APPROVE_USERNAME = False

"""
Player activation
-----------------
ACTIVATE_PLAYER : bool
    Activate player automatically so no email needs to be sent.
    Enabling this option requires a SendGrid API key.
ACTIVATE_LINK : str
    URL player is taken to for activation.
ACTIVATE_REDIRECT : str
    URL to redirect to when player has activated their account
    via email.
"""
ACTIVATE_PLAYER = True
ACTIVATE_LINK = 'http://secure.clubpenguin.com/create/activate/'
ACTIVATE_REDIRECT = ''

"""
Email
-----
SITE_NAME : str
    The name of your site.
FROM_EMAIL : str
    Will appear as the sender for emails sent via the SendGrid
    API.
SENDGRID_API_KEY : str
    Required for sending emails via the SendGrid API.
EMAIL_WHITELIST : list
    List of email domains to accept. If set to an empty list
    or `None` then dash will assume all email domains are
    accepted.
MAX_ACCOUNT_EMAIL : int
    Number of accounts which can be tied to a single email
    address.
.. SendGrid registration:
    https://signup.sendgrid.com/
"""
SITE_NAME = 'Houdini'
FROM_EMAIL = 'noreply@houdi.ni'
SENDGRID_API_KEY = ''
EMAIL_WHITELIST = ['gmail.com', 'hotmail.com']
MAX_ACCOUNT_EMAIL = 5

"""
Cryptography
------------
STATIC_KEY : str
    Static key used to hash passwords. Should not be
    changed unless required by login server auth.
"""
STATIC_KEY = 'houdini'
