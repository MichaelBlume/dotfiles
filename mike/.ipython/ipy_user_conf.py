""" User configuration file for IPython

This is a more flexible and safe way to configure ipython than *rc files
(ipythonrc, ipythonrc-pysh etc.)

This file is always imported on ipython startup. You can import the
ipython extensions you need here (see IPython/Extensions directory).

Feel free to edit this file to customize your ipython experience.

Note that as such this file does nothing, for backwards compatibility.
Consult e.g. file 'ipy_profile_sh.py' for an example of the things 
you can do here.

See http://ipython.scipy.org/moin/IpythonExtensionApi for detailed
description on what you could do here.
"""

# Most of your config files and extensions will probably start with this import

import IPython.ipapi
ip = IPython.ipapi.get()

# You probably want to uncomment this if you did %upgrade -nolegacy
# import ipy_defaults    

import os   

def main():   

    # uncomment if you want to get ipython -p sh behaviour
    # without having to use command line switches  
    # import ipy_profile_sh

    # Configure your favourite editor?
    # Good idea e.g. for %edit os.path.isfile

    #import ipy_editors
    
    # Choose one of these:
    
    #ipy_editors.scite()
    #ipy_editors.scite('c:/opt/scite/scite.exe')
    #ipy_editors.komodo()
    #ipy_editors.idle()
    # ... or many others, try 'ipy_editors??' after import to see them
    
    # Or roll your own:
    #ipy_editors.install_editor("c:/opt/jed +$line $file")
    
    
    o = ip.options
    # An example on how to set options
    #o.autocall = 1
    o.system_verbose = 0
    
    #import_all("os sys")
    #execf('~/_ipython/ns.py')


    # -- prompt
    # A different, more compact set of prompts from the default ones, that
    # always show your current location in the filesystem:

    #o.prompt_in1 = r'\C_LightBlue[\C_LightCyan\Y2\C_LightBlue]\C_Normal\n\C_Green|\#>'
    #o.prompt_in2 = r'.\D: '
    #o.prompt_out = r'[\#] '
    try:
        from django.conf import settings
    except:
        pass
    else:
        dep = settings.DEPLOYMENT
        prompt_dep = dep != 'office' and (dep.upper() + ' ') or ''
        o.prompt_in1 = prompt_dep + o.prompt_in1

    
    # Try one of these color settings if you can't read the text easily
    # autoexec is a list of IPython commands to execute on startup
    #o.autoexec.append('%colors LightBG')
    #o.autoexec.append('%colors NoColor')
    #o.autoexec.append('%colors Linux')
    
    # for sane integer division that converts to float (1/2 == 0.5)
    o.autoexec.append('from __future__ import division')
    
    # For %tasks and %kill
    #import jobctrl 
    
    # For autoreloading of modules (%autoreload, %aimport)    
    import ipy_autoreload
    
    # For winpdb support (%wdb)
    #import ipy_winpdb
    
    # For bzr completer, requires bzrlib (the python installation of bzr)
    #ip.load('ipy_bzr')
    
    # Tab completer that is not quite so picky (i.e. 
    # "foo".<TAB> and str(2).<TAB> will work). Complete 
    # at your own risk!
    #import ipy_greedycompleter
    
    # If you are on Linux, you may be annoyed by
    # "Display all N possibilities? (y or n)" on tab completion,
    # as well as the paging through "more". Uncomment the following
    # lines to disable that behaviour
    #import readline
    #readline.parse_and_bind('set completion-query-items 1000')
    #readline.parse_and_bind('set page-completions no')


# some config helper functions you can use 
def import_all(modules):
    """ Usage: import_all("os sys") """ 
    for m in modules.split():
        ip.ex("from %s import *" % m)

def execf(fname):
    """ Execute a file in user namespace """
    ip.ex('execfile("%s")' % os.path.expanduser(fname))

main()

try:
    ip.ex("from django.conf import settings")
except ImportError:
    pass

def subget(subdomain):
    from app.customer.models import Customer
    return Customer.objects.subget(subdomain)
ip.to_user_ns('subget')

def subdelete(subdomain, force=False):
    if 'test' not in subdomain and not force:
        print 'you sure about that?'
        return
    c=subget(subdomain)
    c.delete(c.getOwner())
ip.to_user_ns('subdelete')

try:
    logdog = subget('logdog')
    from django.contrib.auth.models import User
    myuser = User.objects.get(username='logdog_mike')
    myprofile = myuser.get_profile()
except:
    pass
else:
    ip.to_user_ns('logdog myuser myprofile')

#lemme use GAE API in shell.

import sys

DIR_PATH = "/home/mike/workspace/google_appengine"

EXTRA_PATHS = [
  DIR_PATH,
  os.path.join(DIR_PATH, 'lib', 'antlr3'),
  os.path.join(DIR_PATH, 'lib', 'django'),
  os.path.join(DIR_PATH, 'lib', 'fancy_urllib'),
  os.path.join(DIR_PATH, 'lib', 'ipaddr'),
  os.path.join(DIR_PATH, 'lib', 'webob'),
  os.path.join(DIR_PATH, 'lib', 'yaml', 'lib'),
  os.path.join(DIR_PATH, 'lib', 'simplejson'),
  os.path.join(DIR_PATH, 'lib', 'graphy'),
]

sys.path = EXTRA_PATHS + sys.path

try:
    from google.appengine.api import apiproxy_stub_map
    from google.appengine.api import urlfetch_stub
except:
    pass
else:
    apiproxy_stub_map.apiproxy = apiproxy_stub_map.APIProxyStubMap()
    apiproxy_stub_map.apiproxy.RegisterStub('urlfetch', urlfetch_stub.URLFetchServiceStub())
