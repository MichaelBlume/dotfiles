#
# Copyright (c)2011. Loggly, Inc.
#
# Fabric file for common maintenence tasks
#
# fab -R <role> to target a set of hosts
#

from fabric.api import env, run, sudo, cd, roles

env.roledefs = {
        'ivan': ['frontend-ivan2.office.loggly.net',],
        'prod': ['frontend5.prod.loggly.net','frontend6.prod.loggly.net','frontend7.prod.loggly.net'],
        'engineyard': ['frontend1.engineyard.loggly.net',],
        'hoover': ['frontend1.hoover.loggly.net',],
        'office': ['frontend1.office.loggly.net',],
        'prod_worker': ['frontend5.prod.loggly.net',],
}

LOGGLY_WEB_DIR = '/opt/loggly/web'

def hostname():
    """ Reports the hostname of the target. """
    run('hostname')

def listpackages(match='loggly'):
    """ Lists Loggly debian packages on the target. """
    run('/usr/bin/dpkg -l | grep %s' % match)

def puppetnow():
    """ Forces a run of puppetnow on the target. """
    sudo('/usr/local/bin/puppetnow')

@roles('prod_worker')
def prod_migrate():
    """ Runs the South migrations in the prod deployment. """
    with cd ( LOGGLY_WEB_DIR + '/app'):
        run('./manage.py migrate')

@roles('prod_worker')
def prod_cleanup():
    """ Runs the Django management command to clean up
        the django_session table in prod.
    """
    with cd ( LOGGLY_WEB_DIR + '/app'):
        run('./manage.py cleanup')
