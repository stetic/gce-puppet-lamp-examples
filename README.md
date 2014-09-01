# Example manifests for "How to automate Google Compute Engine with Puppet"

A collection of Puppet manifest examples from our blog post [How to automate Google Compute Engine with Puppet: 
Highly Available LAMP Stack with MongoDB](https://www.4stats.de/developer/google-compute-engine-puppet-lamp.html).

With these manifests you can create a cluster on Google's Compute Engine with two load balanced web instances and
three replicated MongoDB instances.

1. Create the Puppet Master instance

   ```bash
   puppet apply --certname my_project puppetmaster_up.pp
   ```
2. SSH into the Puppet master

   ```bash
   gcutil ssh puppet-master
   ```
3. Authorize the Puppet master

   ```bash
   sudo gcloud auth login
   ```
4. Put the files from this repo in /etc/puppet/manifests
5. Launch the instances

   ```bash
   sudo puppet apply --certname my_project /etc/puppet/manifests/cluster_up.pp
   ```

