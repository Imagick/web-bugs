-- ts1     bug created date
-- ts2     bug last updated date
-- passwd  user password

CREATE TABLE bugdb (
  id int(8) NOT NULL auto_increment,
  package_name varchar(80) default NULL,
  bug_type varchar(32) NOT NULL default 'Bug',
  handle varchar(20) NOT NULL default '',
  email varchar(40) NOT NULL default '',
  reporter_name varchar(80) default '',
  sdesc varchar(80) NOT NULL default '',
  ldesc text NOT NULL,
  package_version varchar(100) default NULL,
  php_version varchar(100) default NULL,
  php_os varchar(32) default NULL,
  status varchar(16) default NULL,
  ts1 datetime default NULL,
  ts2 datetime default NULL,
  assign varchar(20) default NULL,
  passwd varchar(20) default NULL,
  registered tinyint(1) NOT NULL default 0,
  PRIMARY KEY  (id),
  KEY php_version (php_version(1)),
  KEY package_version (package_version(1)),
  KEY package_name(package_name),
  FULLTEXT KEY email (email,sdesc,ldesc)
) TYPE=MyISAM;

CREATE TABLE bugdb_comments (
  id int(8) NOT NULL auto_increment,
  bug int(8) NOT NULL default '0',
  email varchar(40) NOT NULL default '',
  handle varchar(20) NOT NULL default '',
  reporter_name varchar(80) default '',
  ts datetime NOT NULL default '0000-00-00 00:00:00',
  comment text NOT NULL,
  PRIMARY KEY  (id),
  FULLTEXT KEY comment (comment),
  INDEX bug (bug, id, ts)
) TYPE=MyISAM;

-- score's value can be 1 through 5

CREATE TABLE bugdb_votes (
  bug int(8) NOT NULL default '0',
  ts timestamp(14) NOT NULL,
  ip int(10) unsigned NOT NULL default '0',
  score int(3) NOT NULL default '0',
  reproduced int(1) NOT NULL default '0',
  tried int(1) NOT NULL default '0',
  sameos int(1) default NULL,
  samever int(1) default NULL
) TYPE=MyISAM;

CREATE TABLE `bugdb_subscribe` (
  bug_id int(8) NOT NULL default '0',
  email varchar(40) NOT NULL default '',
  unsubscribe_date int(11) default NULL,
  unsubscribe_hash varchar(80) default '',
  PRIMARY KEY  (bug_id, email),
  KEY (unsubscribe_hash)
) TYPE=MyISAM;

CREATE TABLE bugdb_roadmap_link (
  id int(8) NOT NULL auto_increment,
  roadmap_id int(8) NOT NULL default 0,
  PRIMARY KEY  (id, roadmap_id)
);

CREATE TABLE bugdb_roadmap (
  id int(8) NOT NULL auto_increment,
  package varchar(80) NOT NULL default '',
  roadmap_version varchar(100) NOT NULL,
  releasedate datetime NOT NULL default '0000-00-00',
  description text NOT NULL,
  PRIMARY KEY  (id),
  UNIQUE KEY (package, roadmap_version)
);

CREATE TABLE bugdb_patchtracker (
  bugdb_id int(8) NOT NULL,
  patch varchar(40) NOT NULL,
  revision int(8) NOT NULL,
  developer varchar(20) NOT NULL,
  PRIMARY KEY (bugdb_id, patch, revision)
);

CREATE TABLE bugdb_obsoletes_patches (
  bugdb_id int(8) NOT NULL,
  patch varchar(40) NOT NULL,
  revision int(8) NOT NULL,
  obsolete_patch varchar(40) NOT NULL,
  obsolete_revision int(8) NOT NULL,
  PRIMARY KEY (bugdb_id, patch, revision,
               obsolete_patch, obsolete_revision)
);

CREATE TABLE bug_account_request (
  id INT NOT NULL AUTO_INCREMENT,
  created_on DATE NOT NULL,
  handle VARCHAR(20) NOT NULL,
  salt CHAR(32) NOT NULL,
  email VARCHAR(65) NOT NULL,
  PRIMARY KEY(id)
);

CREATE TABLE bugdb_resolves (
  id INT NOT NULL AUTO_INCREMENT,
  status varchar(16) default NULL,
  title varchar(100) NOT NULL,
  message text NOT NULL,
  PRIMARY KEY (id)
);

CREATE TABLE bugdb_packages (
  id INT NOT NULL AUTO_INCREMENT,
  parent INT NOT NULL default '0',
  package_key varchar(80) NOT NULL default '',
  package_name varchar(100) NOT NULL default '',
  project varchar(40) NOT NULL default '',
  PRIMARY KEY (id),
  UNIQUE KEY (package_key, project)
);

# Default pseudo packages (common for all projects)
INSERT INTO bugdb_packages SET id = '1', parent = '0', package_key = 'Web Site',   package_name = 'Web Site',   project = '';
INSERT INTO bugdb_packages SET id = '2', parent = '1', package_key = 'Bug System', package_name = 'Bug System', project = '';

# PEAR specific pseudo packages
INSERT INTO bugdb_packages SET id = '3', parent = '1', package_key = 'PEPr', package_name = 'PEPr', project = 'pear';
INSERT INTO bugdb_packages SET id = '4', parent = '0', package_key = 'Documentation', package_name = 'Documentation', project = 'pear';

# PECL specific pseudo pacakges
# none?
