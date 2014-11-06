<?php
// must be run within Dokuwiki
if(!defined('DOKU_INC')) die();

/**
 * Specifif LemonLDAP authentication backend
 *
 * @license   GPL 2 (http://www.gnu.org/licenses/gpl.html)
 * @author    Nicolas Leclerc <nl@spirotron.fr>
 */
class auth_plugin_authlemonldap extends DokuWiki_Auth_Plugin {
	/**
	 * Constructor
	 */
	public function __construct() {
		parent::__construct();

		global $conf;

		$this->cando['external'] = true;
	}

	public function trustExternal($user,$pass,$sticky=false) {
		global $USERINFO;

		$headers = getallheaders();
		$userId = $headers['Auth-User'].':'.preg_replace('/\W*/','',$headers['User-Fullname']); # Show fullname in userid to

		if (!$userId)
			return false;

		$userData = $this->getUserData($userId);

		foreach ($userData as $key => $value)
			$USERINFO[$key] = $value;

        $_SERVER['REMOTE_USER'] = $userId; //userid
        $_SESSION[DOKU_COOKIE]['auth']['user'] = $userId; //userid
        $_SESSION[DOKU_COOKIE]['auth']['info'] = $USERINFO;

		return true;
	}

	public function getUserData($user, $requireGroups=true) {
		$headers = getallheaders();

		$groups = [];

		if ($headers['Is-Member'])
			$groups[] = 'member';

		if ($headers['Is-Admin'])
			$groups[] = 'admin';

		if ($headers['Is-Blogger'])
			$groups[] = 'blogger';

		return [
			'name' => $headers['User-Fullname'],
			'mail' => $headers['User-Email'],
			'grps' => $groups,
		];
	}

	public function logOff() {
		header('Location: /logout');
	}
}
