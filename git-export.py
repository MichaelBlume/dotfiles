#! /usr/bin/env python

import sys

from os import listdir
from time import sleep
import envoy

BRANCH_MAP = {
  'default': 'master'
}

def run(cmd):
    print cmd
    r = envoy.run(cmd)
    print r.std_out
    if r.status_code:
        sys.exit(1)

class GitExporter(object):
    def __init__(self):
        self.git_branches = {bn: None for bn in
                             listdir('.git/refs/remotes/mirror')}

    def main(self):
        """Update hg, export to git and push up references."""

        run('hg pull -u')
        run('hg gexport')

        hg_branches = {}
        hg_heads = envoy.run('hg branches --debug --active').std_out

        for line in hg_heads.strip().split('\n'):
            branch, full_rev = line.split()
            branch = BRANCH_MAP.get(branch, branch)
            _local, rev = full_rev.split(':')
            hg_branches[branch] = rev

        hg2git = {}
        mapfile = open('.hg/git-mapfile', 'rb')

        for line in mapfile:
            gitsha, hgsha = line.strip().split(' ', 1)
            hg2git[hgsha] = gitsha

        mapfile.close()

        add = set()
        remove = set()

        for branch, hgsha in hg_branches.iteritems():
            git_ref = hg2git[hgsha]
            if self.git_branches.get(branch) != git_ref:
                add.add(branch)
                self.git_branches[branch] = git_ref

        for branch in self.git_branches:
            if branch not in hg_branches:
                remove.add(branch)

        if remove:
            for branch in remove:
                print "# Removing Branch:", branch
                run('git push mirror :' + branch)
                del self.git_branches[branch]

        print "# Updating Branches"
        for branch in add:
            ref = self.git_branches[branch]
            run('git push -f mirror %s:refs/heads/%s' % (ref, branch))

    def runloop(self):
        while 1:
            print "# Syncing"
            self.main()
            print "# Sleeping"
            sleep(60 * 10)

GitExporter().runloop()
