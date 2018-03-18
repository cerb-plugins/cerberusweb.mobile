<?php
if (class_exists('Extension_AppPreBodyRenderer',true)):
	class MobilePreBodyRenderer extends Extension_AppPreBodyRenderer {
		function render() {
			$tpl = DevblocksPlatform::services()->template();
			$tpl->display('devblocks:cerberusweb.mobile::prebody.tpl');
		}
	};
endif;

class Controller_Mobile extends DevblocksControllerExtension {
	function isVisible() {
		// The current session must be a logged-in worker to use this page.
		if(null == ($worker = CerberusApplication::getActiveWorker()))
			return false;
		return true;
	}

	/*
	 * Request Overload
	 */
	function handleRequest(DevblocksHttpRequest $request) {
		$active_worker = CerberusApplication::getActiveWorker();
		
		// If we're not logged in, redirect to a login form
		if(empty($active_worker)) {
			$query = array();
			
			if(is_array($request->path) && !empty($request->path))
				$query = array('url'=> urlencode(implode('/',$request->path)));
			
			DevblocksPlatform::redirect(new DevblocksHttpRequest(array('login'), $query));
			exit;
		}
		
		$stack = $request->path;
		array_shift($stack); // m

		if(isset($_POST['c']) && isset($_POST['a'])) {
			@$c = DevblocksPlatform::importGPC($_POST['c'], 'string', '');
			@$a = DevblocksPlatform::importGPC($_POST['a'], 'string', '');
			
			if(!empty($c) && !empty($a))
				$stack = array($a);
		}
		
		@$action = array_shift($stack) . 'Action';
		
		switch($action) {
			case NULL:
				// [TODO] Index/page render
				break;
				
			default:
				// Default action, call arg as a method suffixed with Action
				if(method_exists($this,$action)) {
					call_user_func(array(&$this, $action));
				}
				break;
		}
	}

	function writeResponse(DevblocksHttpResponse $response) {
		$stack = $response->path;
		
		@array_shift($stack); // m
		@$controller = array_shift($stack);
		
		////////////
		$tpl = DevblocksPlatform::services()->template();
		$translate = DevblocksPlatform::getTranslationService();
		$settings = DevblocksPlatform::services()->pluginSettings();
		$active_worker = CerberusApplication::getActiveWorker();
		$visit = CerberusApplication::getVisit();
		
		$tpl->assign('active_worker', $active_worker);
		
		if($active_worker instanceof Model_Worker)
			$tpl->assign('active_worker_memberships', $active_worker->getMemberships());
		
		$tpl->assign('visit', $visit);
		$tpl->assign('session', $_SESSION);
		$tpl->assign('translate', $translate);
		$tpl->assign('settings', $settings);
		$tpl->assign('controller', $controller);
		$tpl->assign('response_path', '/' . implode('/', $response->path));
		
		$notification_count = DAO_Notification::getUnreadCountByWorker($active_worker->id);
		$tpl->assign('notification_count', $notification_count);
		
		$plugin_manifest = DevblocksPlatform::getPlugin('cerberusweb.mobile');
		$tpl->assign('plugin_manifest', $plugin_manifest);
		////////////
		
		switch($controller) {
			case 'compose':
				$this->_renderCompose($stack);
				break;
				
			default:
			case 'notifications':
				$this->_renderNotifications($stack);
				break;
				
			case 'bots':
				@$bot_id = array_shift($stack);
				@$behavior_id = array_shift($stack);
				
				if(is_numeric($bot_id) && is_numeric($behavior_id)) {
					array_unshift($stack, intval($bot_id), intval($behavior_id));
					$this->_renderBotChat($stack);
					return;
				}
				
				switch($request) {
					default:
						$this->_renderBots([]);
						break;
				}
				
				break;
				
			case 'pages':
				$this->_renderPages($stack);
				break;
				
			case 'profile':
				$this->_renderProfile($stack);
				break;
				
			case 'search':
				if(empty($stack)) {
					$this->_renderSearch($stack);
					
				} else {
					$this->_renderSearchWorklist($stack);
					
				}
				break;
				
			case 'settings':
				$this->_renderSettings($stack);
				break;
			
			case 'workspaces':
				$this->_renderWorkspaces($stack);
				break;
				
			case 'workspace':
				@$request = array_shift($stack);
				
				if(is_numeric($request)) {
					array_unshift($stack, $request);
					$this->_renderWorkspace($stack);
					return;
				}
				
				switch($request) {
					case 'tab':
						$this->_renderWorkspaceTab($stack);
						break;
						
					case 'worklist':
						$this->_renderWorkspaceList($stack);
						break;
						
					case 'widget':
						$this->_renderWorkspaceWidget($stack);
						break;
				}
				
				
				break;
		}
	}
	
	function profileAddCommentDialogAction() {
		@$context = DevblocksPlatform::importGPC($_REQUEST['context'], 'string', '');
		@$context_id = DevblocksPlatform::importGPC($_REQUEST['context_id'], 'integer', 0);
		
		$tpl = DevblocksPlatform::services()->template();
		
		$tpl->assign('context', $context);
		$tpl->assign('context_id', $context_id);
		
		$active_worker = CerberusApplication::getActiveWorker();
		$tpl->assign('active_worker', $active_worker);

		$tpl->assign('workers', DAO_Worker::getAllActive());
		
		$tpl->display('devblocks:cerberusweb.mobile::profiles/comments/comment_dialog.tpl');
	}
	
	function saveProfileAddCommentDialogAction() {
		@$context = DevblocksPlatform::importGPC($_REQUEST['context'], 'string', '');
		@$context_id = DevblocksPlatform::importGPC($_REQUEST['context_id'], 'integer', 0);
		@$comment = DevblocksPlatform::importGPC($_REQUEST['comment'], 'string', '');
		
		$active_worker = CerberusApplication::getActiveWorker();

		$also_notify_worker_ids = array_keys(CerberusApplication::getWorkersByAtMentionsText($comment));
		
		$fields = array(
			DAO_Comment::CONTEXT => $context,
			DAO_Comment::CONTEXT_ID => $context_id,
			DAO_Comment::COMMENT => $comment,
			DAO_Comment::CREATED => time(),
			DAO_Comment::OWNER_CONTEXT => CerberusContexts::CONTEXT_WORKER,
			DAO_Comment::OWNER_CONTEXT_ID => $active_worker->id,
		);
		
		DAO_Comment::create($fields, $also_notify_worker_ids);
		
		header('Content-type: application/json');
		
		echo json_encode(array(
			'success' => true,
		));
	}
	
	function profileGetCommentAction() {
		@$id = DevblocksPlatform::importGPC($_REQUEST['id'], 'integer', 0);
		
		$tpl = DevblocksPlatform::services()->template();

		CerberusContexts::getContext(CerberusContexts::CONTEXT_COMMENT, $id, $labels, $values);
		$dict = new DevblocksDictionaryDelegate($values);

		$comments = DAO_Comment::getByContext($dict->context, $dict->context_id);
		$tpl->assign('comments', array_reverse($comments, true));

		$tpl->assign('dict', $dict);
		
		$tpl->display('devblocks:cerberusweb.mobile::profiles/comments/comment.tpl');
	}
	
	function saveComposeAction() {
		@$group_id = DevblocksPlatform::importGPC($_REQUEST['group_id'], 'integer', 0);
		@$bucket_id = DevblocksPlatform::importGPC($_REQUEST['bucket_id'], 'integer', 0);
		@$org = DevblocksPlatform::importGPC($_REQUEST['org'], 'string', '');
		@$to = DevblocksPlatform::importGPC($_REQUEST['to'], 'string', '');
		@$subject = DevblocksPlatform::importGPC($_REQUEST['subject'], 'string', '');
		@$body = DevblocksPlatform::importGPC($_REQUEST['body'], 'string', '');
		@$status = DevblocksPlatform::importGPC($_REQUEST['status'], 'string', '');
		@$reopen_at = DevblocksPlatform::importGPC($_REQUEST['reopen_at'], 'string', '');

		$active_worker = CerberusApplication::getActiveWorker();
		
		$properties = array(
			'group_id' => $group_id,
			'bucket_id' => $bucket_id,
			'worker_id' => $active_worker->id,
			'to' => $to,
			'subject' => $subject,
			'content' => $body,
		);
		
		$hash_commands = array();
		
		$this->_parseComposeHashCommands($active_worker, $properties, $hash_commands);
		
		if(!empty($org) && false != ($org_id = DAO_ContactOrg::lookup($org, true)))
			$properties['org_id'] = $org_id;
		
		switch($status) {
			case 'open':
				$properties['status_id'] = Model_Ticket::STATUS_OPEN;
				break;
				
			case 'waiting':
				$properties['status_id'] = Model_Ticket::STATUS_WAITING;
				$properties['ticket_reopen'] = $reopen_at;
				break;
				
			case 'closed':
				$properties['status_id'] = Model_Ticket::STATUS_CLOSED;
				$properties['ticket_reopen'] = $reopen_at;
				break;
		}
		
		if(false !== ($ticket_id = CerberusMail::compose($properties))) {
			// Run hash commands
			if(!empty($hash_commands))
				$this->_handleComposeHashCommands($hash_commands, $ticket_id, $active_worker);
		}
		
		header('Content-type: application/json');
		
		echo json_encode(array(
			'success' => true,
			'ticket_id' => $ticket_id,
		));
	}
	
	private function _parseComposeHashCommands(Model_worker $worker, array &$message_properties, array &$commands) {
		$lines_in = DevblocksPlatform::parseCrlfString($message_properties['content'], true);
		$lines_out = array();
		
		$is_cut = false;
		
		foreach($lines_in as $line) {
			$handled = false;
			
			if(preg_match('/^\#([A-Za-z0-9_]+)(.*)$/', $line, $matches)) {
				@$command = $matches[1];
				@$args = ltrim($matches[2]);
				
				switch($command) {
					case 'attach':
						@$bundle_tag = $args;
						$handled = true;
						
						if(empty($bundle_tag))
							break;
						
						if(false == ($bundle = DAO_FileBundle::getByTag($bundle_tag)))
							break;
						
						$attachments = $bundle->getAttachments();
						
						$message_properties['link_forward_files'] = true;
						
						if(!isset($message_properties['forward_files']))
							$message_properties['forward_files'] = array();
						
						$message_properties['forward_files'] = array_merge($message_properties['forward_files'], array_keys($attachments));
						break;
					
					case 'cut':
						$is_cut = true;
						$handled = true;
						break;
						
					case 'signature':
						$group = DAO_Group::get($message_properties['group_id']);
						$line = $group->getReplySignature($message_properties['bucket_id'], $worker);
						break;
						
					default:
						$commands[] = array(
							'command' => $command,
							'args' => $args,
						);
						$handled = true;
						break;
				}
			}
			
			if(!$handled && !$is_cut) {
				$lines_out[] = $line;
			}
		}
		
		$message_properties['content'] = implode("\n", $lines_out);
	}
	
	private function _handleComposeHashCommands(array $commands, $ticket_id, Model_Worker $worker) {
		foreach($commands as $command_data) {
			switch($command_data['command']) {
				case 'comment':
					@$comment = $command_data['args'];
					
					if(!empty($comment)) {
						$also_notify_worker_ids = array_keys(CerberusApplication::getWorkersByAtMentionsText($comment));
						
						$fields = array(
							DAO_Comment::CONTEXT => CerberusContexts::CONTEXT_TICKET,
							DAO_Comment::CONTEXT_ID => $ticket_id,
							DAO_Comment::OWNER_CONTEXT => CerberusContexts::CONTEXT_WORKER,
							DAO_Comment::OWNER_CONTEXT_ID => $worker->id,
							DAO_Comment::CREATED => time()+2,
							DAO_Comment::COMMENT => $comment,
						);
						$comment_id = DAO_Comment::create($fields, $also_notify_worker_ids);
					}
					break;
		
				case 'watch':
					CerberusContexts::addWatchers(CerberusContexts::CONTEXT_TICKET, $ticket_id, array($worker->id));
					break;
		
				case 'unwatch':
					CerberusContexts::removeWatchers(CerberusContexts::CONTEXT_TICKET, $ticket_id, array($worker->id));
					break;
			}
		}
	}	
	
	function saveSettingsAction() {
		@$mobile_mail_signature_pos = DevblocksPlatform::importGPC($_REQUEST['mobile_mail_signature_pos'], 'integer', 0);

		$active_worker = CerberusApplication::getActiveWorker();
		
		DAO_WorkerPref::set($active_worker->id, 'mobile_mail_signature_pos', $mobile_mail_signature_pos);
		
		header('Content-type: application/json');
		
		echo json_encode(array(
			'success' => true,
		));
	}
	
	function handleProfileBlockRequestAction() {
		@$extension_id = DevblocksPlatform::importGPC($_REQUEST['extension'], 'string', '');
		@$action = DevblocksPlatform::importGPC($_REQUEST['action'], 'string', '');
		
		if(false == ($ext = Extension_MobileProfileBlock::get($extension_id)))
			return;

		$action .= 'Action';
		
		if(method_exists($ext, $action)) {
			call_user_func(array(&$ext, $action));
		}
	}
	
	function showVaBehaviorDialogAction() {
		@$behavior_id = DevblocksPlatform::importGPC($_REQUEST['behavior_id'], 'integer', 0);
		@$context = DevblocksPlatform::importGPC($_REQUEST['context'], 'string', '');
		@$context_id = DevblocksPlatform::importGPC($_REQUEST['context_id'], 'integer', 0);
		
		$active_worker = CerberusApplication::getActiveWorker();
		$tpl = DevblocksPlatform::services()->template();
		
		$tpl->assign('context', $context);
		$tpl->assign('context_id', $context_id);
		
		if(null == ($behavior = DAO_TriggerEvent::get($behavior_id)))
			return;
		
		if(null == ($va = $behavior->getBot()))
			return;
		
		if(!Context_Bot::isReadableByActor($va, $active_worker))
			return;
		
		$tpl->assign('behavior', $behavior);
		
		// Template
		
		$tpl->display('devblocks:cerberusweb.mobile::profiles/run_va_macro.tpl');
		exit;
	}
	
	function runVaProfileBehaviorAction() {
		@$context = DevblocksPlatform::importGPC($_REQUEST['context'], 'string', '');
		@$context_id = DevblocksPlatform::importGPC($_REQUEST['context_id'], 'integer', 0);
		@$behavior_id = DevblocksPlatform::importGPC($_REQUEST['behavior_id'], 'integer', 0);
		@$when = DevblocksPlatform::importGPC($_REQUEST['when'], 'string', '');
		
		$active_worker = CerberusApplication::getActiveWorker();
		
		if(null == ($behavior = DAO_TriggerEvent::get($behavior_id)))
			return;
		
		if(null == ($va = $behavior->getBot()))
			return;
		
		if(!Context_Bot::isReadableByActor($va, $active_worker))
			return;
		
		if($va->is_disabled)
			return false;
		
		if($behavior->is_disabled)
			return false;
		
		// Vars

		$vars = array();
		
		if(is_array($behavior->variables)) {
			foreach($behavior->variables as $var_key => $var) {
				if(!empty($var['is_private']))
					continue;
				
				// Format passed variables
				
				$var_val = null;
				
				try {
					if(isset($_REQUEST[$var_key]))
						@$var_val = $behavior->formatVariable($var, DevblocksPlatform::importGPC($_REQUEST[$var_key]));
					
				} catch(Exception $e) {
				}
				
				$vars[$var_key] = $var_val;
			}
		}
		
		// Are we scheduling this behavior now or in the future?
		
		$run_timestamp = @strtotime($when) or time();
		
		// Create
		$behavior_id = DAO_ContextScheduledBehavior::create(array(
			DAO_ContextScheduledBehavior::BEHAVIOR_ID => $behavior->id,
			DAO_ContextScheduledBehavior::CONTEXT => $context,
			DAO_ContextScheduledBehavior::CONTEXT_ID => $context_id,
			DAO_ContextScheduledBehavior::RUN_DATE => $run_timestamp,
			DAO_ContextScheduledBehavior::RUN_RELATIVE => '',
			DAO_ContextScheduledBehavior::RUN_LITERAL => $when,
			DAO_ContextScheduledBehavior::VARIABLES_JSON => json_encode($vars),
			DAO_ContextScheduledBehavior::REPEAT_JSON => json_encode(array()),
		));
		
		// Execute now if the start time is in the past
		if($run_timestamp <= time()) {
			$scheduled_behavior = DAO_ContextScheduledBehavior::get($behavior_id);
			$scheduled_behavior->run();
		}
		
		header('Content-type: application/json');
		
		echo json_encode(array(
			'success' => true,
		));
		
		exit;
	}
	
	function viewLoadPresetAction() {
		@$view_id = DevblocksPlatform::importGPC($_REQUEST['view_id'], 'string', '');
		@$hide_filtering = DevblocksPlatform::importGPC($_REQUEST['hide_filtering'], 'integer', 0);
		@$hide_sorting = DevblocksPlatform::importGPC($_REQUEST['hide_sorting'], 'integer', 0);
		@$preset_id = DevblocksPlatform::importGPC($_REQUEST['preset_id'], 'integer', 0);
		
		if(null == ($view = C4_AbstractViewLoader::getView($view_id)))
			return;
		
		if(empty($preset_id)) {
			$view->doResetCriteria();
			
		} else {
			if(false == ($preset = DAO_ViewFiltersPreset::get($preset_id)))
				return;
			
			$view->renderPage = 0;
			$view->addParams($preset->params, true);
			
			$disable_sorting = $view->isCustom() && @$view->options['disable_sorting'];
				
			if(!$disable_sorting) {
				$view->renderSortAsc = $preset->sort_asc;
				$view->renderSortBy = $preset->sort_by;
			}
		}
		
		$tpl = DevblocksPlatform::services()->template();
		$tpl->assign('view', $view);
		$tpl->assign('hide_filtering', $hide_filtering);
		$tpl->assign('hide_sorting', $hide_sorting);
		$tpl->display('devblocks:cerberusweb.mobile::workspaces/worklist_view.tpl');
		exit;
	}
	
	function viewQuickSearchAction() {
		@$view_id = DevblocksPlatform::importGPC($_REQUEST['view_id'], 'string', '');
		@$hide_filtering = DevblocksPlatform::importGPC($_REQUEST['hide_filtering'], 'integer', 0);
		@$hide_sorting = DevblocksPlatform::importGPC($_REQUEST['hide_sorting'], 'integer', 0);
		@$q = DevblocksPlatform::importGPC($_REQUEST['q'], 'string', '');
		
		if(null == ($view = C4_AbstractViewLoader::getView($view_id)))
			return;

		$view->addParamsWithQuickSearch($q);
		$view->renderPage = 0;
		
		$tpl = DevblocksPlatform::services()->template();
		$tpl->assign('view', $view);
		$tpl->assign('hide_filtering', $hide_filtering);
		$tpl->assign('hide_sorting', $hide_sorting);
		$tpl->display('devblocks:cerberusweb.mobile::workspaces/worklist_view.tpl');
		exit;
	}
	
	function viewRemoveFilterAction() {
		@$view_id = DevblocksPlatform::importGPC($_REQUEST['view_id'], 'string', '');
		@$hide_filtering = DevblocksPlatform::importGPC($_REQUEST['hide_filtering'], 'integer', 0);
		@$hide_sorting = DevblocksPlatform::importGPC($_REQUEST['hide_sorting'], 'integer', 0);
		@$filter_key = DevblocksPlatform::importGPC($_REQUEST['filter_key'], 'string', '');
		
		if(null == ($view = C4_AbstractViewLoader::getView($view_id)))
			return;

		if('*' == $filter_key) {
			$view->removeAllParams();
			
		} else {
			$view->removeParam($filter_key);
		}
		
		$view->renderPage = 0;
		
		$tpl = DevblocksPlatform::services()->template();
		$tpl->assign('view', $view);
		$tpl->display('devblocks:cerberusweb.mobile::workspaces/worklist_view.tpl');
		exit;
	}
	
	function viewPageAction() {
		@$view_id = DevblocksPlatform::importGPC($_REQUEST['view_id'], 'string', '');
		@$hide_filtering = DevblocksPlatform::importGPC($_REQUEST['hide_filtering'], 'integer', 0);
		@$hide_sorting = DevblocksPlatform::importGPC($_REQUEST['hide_sorting'], 'integer', 0);
		@$page = DevblocksPlatform::importGPC($_REQUEST['page'], 'integer', 0);
		
		if(null == ($view = C4_AbstractViewLoader::getView($view_id)))
			return;

		$view->doPage($page);
		
		$tpl = DevblocksPlatform::services()->template();
		$tpl->assign('view', $view);
		$tpl->assign('hide_filtering', $hide_filtering);
		$tpl->assign('hide_sorting', $hide_sorting);
		$tpl->display('devblocks:cerberusweb.mobile::workspaces/worklist_view.tpl');
		exit;
	}
	
	function viewSortByAction() {
		@$view_id = DevblocksPlatform::importGPC($_REQUEST['view_id'], 'string', '');
		@$hide_filtering = DevblocksPlatform::importGPC($_REQUEST['hide_filtering'], 'integer', 0);
		@$hide_sorting = DevblocksPlatform::importGPC($_REQUEST['hide_sorting'], 'integer', 0);
		@$sort_by = DevblocksPlatform::importGPC($_REQUEST['sort_by'], 'string', '');
		@$sort_asc = DevblocksPlatform::importGPC($_REQUEST['sort_asc'], 'integer', 0);
		
		if(null == ($view = C4_AbstractViewLoader::getView($view_id)))
			return;

		$view->renderSortBy = $sort_by;
		$view->renderSortAsc = $sort_asc ? 1 : 0;
		$view->renderPage = 0;
		
		$tpl = DevblocksPlatform::services()->template();
		$tpl->assign('view', $view);
		$tpl->assign('hide_filtering', $hide_filtering);
		$tpl->assign('hide_sorting', $hide_sorting);
		$tpl->display('devblocks:cerberusweb.mobile::workspaces/worklist_view.tpl');
		exit;
	}
	
	private function _renderCompose($stack) {
		$active_worker = CerberusApplication::getActiveWorker();
		$tpl = DevblocksPlatform::services()->template();
		
		@$to = DevblocksPlatform::importGPC($_REQUEST['to'], 'string', '');
		$tpl->assign('to', $to);
		
		$groups = DAO_Group::getAll();
		$tpl->assign('groups', $groups);
		
		$buckets = DAO_Bucket::getAll();
		$tpl->assign('buckets', $buckets);
		
		$tpl->display('devblocks:cerberusweb.mobile::compose/index.tpl');
	}
	
	private function _renderSettings($stack) {
		$active_worker = CerberusApplication::getActiveWorker();
		$tpl = DevblocksPlatform::services()->template();
		
		$worker_prefs = DAO_WorkerPref::getByWorker($active_worker->id);
		$tpl->assign('worker_prefs', $worker_prefs);
		
		$tpl->display('devblocks:cerberusweb.mobile::settings/index.tpl');
	}
	
	private function _renderNotifications($stack) {
		$active_worker = CerberusApplication::getActiveWorker();
		
		$tpl = DevblocksPlatform::services()->template();
		
		$notifications = DAO_Notification::getWhere(sprintf("%s = %d AND %s = %d",
			DAO_Notification::WORKER_ID,
			$active_worker->id,
			DAO_Notification::IS_READ,
			0
		));
		
		$tpl->assign('notifications', $notifications);
		
		$tpl->display('devblocks:cerberusweb.mobile::notifications/index.tpl');
	}
	
	private function _renderPages($stack) {
		$active_worker = CerberusApplication::getActiveWorker();
		
		$tpl = DevblocksPlatform::services()->template();
		
		$tpl->assign('page_title', 'Pages');
		
		$workspaces = DAO_WorkspacePage::getByWorker($active_worker);
		$tpl->assign('workspaces', $workspaces);
		
		$tpl->display('devblocks:cerberusweb.mobile::workspaces/index.tpl');
	}
	
	private function _renderProfile($stack) {
		@$context = array_shift($stack);
		@$context_id = intval(array_shift($stack));

		$active_worker = CerberusApplication::getActiveWorker();
		$tpl = DevblocksPlatform::services()->template();
		
		if(false == ($context_ext = Extension_DevblocksContext::getByAlias($context, true)))
		if(false == ($context_ext = Extension_DevblocksContext::get($context)))
			return;
		
		$context = $context_ext->id;
		
		if(false === CerberusContexts::isReadableByActor($context, $context_id, $active_worker))
			return;
		
		$tpl->assign('context', $context);
		$tpl->assign('context_ext', $context_ext);
		$tpl->assign('context_id', $context_id);
		
		CerberusContexts::getContext($context, $context_id, $labels, $values, null, true, false);

		$dict = new DevblocksDictionaryDelegate($values);
		$tpl->assign('dict', $dict);

		$tpl->assign('types', $dict->_types);
		
		// Load mobile profile extensions
		
		$mobile_profile_extensions = Extension_MobileProfileBlock::getAll(true, $context);
		$tpl->assign('mobile_profile_extensions', $mobile_profile_extensions);

		// Comments
		
		if($context_ext instanceof IDevblocksContextProfile) {
			$comments = DAO_Comment::getByContext($context, $context_id);
			$tpl->assign('comments', array_reverse($comments, true));
		}
		
		$tpl->display('devblocks:cerberusweb.mobile::profiles/profile.tpl');
	}
	
	private function _renderSearch($stack) {
		$active_worker = CerberusApplication::getActiveWorker();
		
		$tpl = DevblocksPlatform::services()->template();
		
		$contexts = Extension_DevblocksContext::getAll(false, ['search']);
		$tpl->assign('contexts', $contexts);
		
		$tpl->display('devblocks:cerberusweb.mobile::search/index.tpl');
	}
	
	private function _renderSearchWorklist($stack) {
		@$q = DevblocksPlatform::importGPC($_REQUEST['q'], 'string', '');
		
		@$context_ext_id = array_shift($stack);
		
		if(empty($context_ext_id))
			return false;
		
		if(false == ($context_ext = Extension_DevblocksContext::getByAlias($context_ext_id, true)))
		if(false == ($context_ext = Extension_DevblocksContext::get($context_ext_id, true)))
			return false;
		
		$context_ext_id = $context_ext->id;
		
		$active_worker = CerberusApplication::getActiveWorker();
		
		$tpl = DevblocksPlatform::services()->template();

		$tpl->assign('context_ext', $context_ext);
		
		if(false == ($view = $context_ext->getSearchView()))
			return false;
		
		if(!empty($q)) {
			$view->addParamsWithQuickSearch($q, true);
			$view->renderPage = 0;
		}
		
		$view->renderLimit = 10;
		$view->renderTotal = true;
		
		$tpl->assign('view', $view);
		
		$tpl->display('devblocks:cerberusweb.mobile::search/worklist.tpl');
	}
	
	private function _renderWorkspaces($stack) {
		$active_worker = CerberusApplication::getActiveWorker();
		
		$tpl = DevblocksPlatform::services()->template();
		
		$pages = DAO_WorkspacePage::getByWorker($active_worker);
		$workspaces = array();
		
		if(null != ($menu_json = DAO_WorkerPref::get($active_worker->id, 'menu_json', null))) {
			@$menu = json_decode($menu_json);
			foreach($menu as $page_id)
				if(isset($pages[$page_id]))
				$workspaces[$page_id] = $pages[$page_id];
				
			$tpl->assign('menu', $menu);
		}

		if(empty($workspaces))
			$workspaces = $pages;
		
		$tpl->assign('workspaces', $workspaces);
		
		$tpl->display('devblocks:cerberusweb.mobile::workspaces/index.tpl');
	}
	
	private function _renderWorkspace($stack) {
		@$workspace_id = array_shift($stack);

		$active_worker = CerberusApplication::getActiveWorker();
		$tpl = DevblocksPlatform::services()->template();
		
		$workspaces = DAO_WorkspacePage::getByWorker($active_worker);
		
		if(!isset($workspaces[$workspace_id]))
			return;
		
		$workspace_page = $workspaces[$workspace_id]; /* @var $workspace_page Model_WorkspacePage */
		$tpl->assign('workspace', $workspace_page);
		
		$workspace_tabs = $workspace_page->getTabs($active_worker);
		$tpl->assign('workspace_tabs', $workspace_tabs);
		
		$tpl->display('devblocks:cerberusweb.mobile::workspaces/page.tpl');
	}
	
	private function _renderWorkspaceTab($stack) {
		@$workspace_tab_id = array_shift($stack);
		
		$active_worker = CerberusApplication::getActiveWorker();
		$tpl = DevblocksPlatform::services()->template();
		
		$workspace_tab = DAO_WorkspaceTab::get($workspace_tab_id);
		$tpl->assign('workspace_tab', $workspace_tab);
		
		$workspaces = DAO_WorkspacePage::getByWorker($active_worker);
		
		if(!isset($workspaces[$workspace_tab->workspace_page_id]))
			return;
		
		$workspace_page = $workspace_tab->getWorkspacePage();
		$tpl->assign('workspace_page', $workspace_page);

		// [TODO] Tab type handling (move to extensions)
		
		switch($workspace_tab->extension_id) {
			case 'core.workspace.tab':
				$workspace_widgets = DAO_WorkspaceWidget::getByTab($workspace_tab_id);
				$tpl->assign('workspace_widgets', $workspace_widgets);
				break;
				
			case 'core.workspace.tab.worklists':
				$workspace_lists = DAO_WorkspaceList::getByTab($workspace_tab_id);
				$tpl->assign('workspace_lists', $workspace_lists);
				break;
				
			case 'core.workspace.tab.calendar':
				$calendar_id = $workspace_tab->params['calendar_id'];
				CerberusContexts::getContext(CerberusContexts::CONTEXT_CALENDAR, $calendar_id, $labels, $values);
				$dict = new DevblocksDictionaryDelegate($values);
				$tpl->assign('dict', $dict);
				break;
		}
		
		$tpl->display('devblocks:cerberusweb.mobile::workspaces/tab.tpl');
	}
	
	private function _renderWorkspaceList($stack) {
		@$workspace_list_id = array_shift($stack);

		$active_worker = CerberusApplication::getActiveWorker();
		$tpl = DevblocksPlatform::services()->template();
		
		$worklist = DAO_WorkspaceList::get($workspace_list_id);

		$view_id = 'cust_' . $worklist->id;
		
		// Make sure our workspace source has a valid renderer class
		if(null == ($ext = Extension_DevblocksContext::get($worklist->context))) {
			return;
		}
		
		if(null == ($view = C4_AbstractViewLoader::getView($view_id))) {
			$view = $ext->getChooserView($view_id);  /* @var $view C4_AbstractView */
				
			if(empty($view))
				return;
				
			$view->name = $worklist->name;
			$view->renderLimit = $worklist->render_limit;
			$view->renderPage = 0;
			$view->is_ephemeral = 0;
			$view->view_columns = $worklist->columns;
			$view->addParams($worklist->getParamsEditable(), true);
			$view->addParamsRequired($worklist->getParamsRequired(), true);
			$view->renderSortBy = array_keys($worklist->render_sort);
			$view->renderSortAsc = array_values($worklist->render_sort);
			$view->renderSubtotals = $worklist->render_subtotals;
		}
	
		if(!empty($view)) {
			if($active_worker) {
				$labels = array();
				$values = array();
				$active_worker->getPlaceholderLabelsValues($labels, $values);
				
				$view->setPlaceholderLabels($labels);
				$view->setPlaceholderValues($values);
			}
		}
		
		$tpl->assign('view', $view);
		
		$workspace_tab = DAO_WorkspaceTab::get($worklist->workspace_tab_id);
		$tpl->assign('workspace_tab', $workspace_tab);
		
		$workspace_page = $workspace_tab->getWorkspacePage();
		$tpl->assign('workspace_page', $workspace_page);

		$tpl->display('devblocks:cerberusweb.mobile::workspaces/worklist.tpl');
	}
	
	private function _renderWorkspaceWidget($stack) {
		@$workspace_widget_id = array_shift($stack);
		
		$active_worker = CerberusApplication::getActiveWorker();
		$tpl = DevblocksPlatform::services()->template();
		
		$widget = DAO_WorkspaceWidget::get($workspace_widget_id);
		$tpl->assign('widget', $widget);
		
		$widget_extension = Extension_WorkspaceWidget::get($widget->extension_id);
		$tpl->assign('widget_extension', $widget_extension);
		
		$workspace_tab = DAO_WorkspaceTab::get($widget->workspace_tab_id);
		$tpl->assign('workspace_tab', $workspace_tab);
		
		$workspace_page = $workspace_tab->getWorkspacePage();
		$tpl->assign('workspace_page', $workspace_page);

		// [TODO] Mobile widget overrides should come from extensions
		
		if($widget_extension->id == 'core.workspace.widget.worklist') {
			$view = $widget_extension->getView($widget);
			$tpl->assign('view', $view);
			
		} elseif($widget_extension->id == 'core.workspace.widget.calendar') {
			$calendar_id = $widget->params['calendar_id'];
			CerberusContexts::getContext(CerberusContexts::CONTEXT_CALENDAR, $calendar_id, $labels, $values);
			$dict = new DevblocksDictionaryDelegate($values);
			$tpl->assign('dict', $dict);
		}
		
		$tpl->display('devblocks:cerberusweb.mobile::workspaces/widget.tpl');
	}
	
	/* Bots */
	
	private function _renderBots($stack) {
		$active_worker = CerberusApplication::getActiveWorker();
		
		$tpl = DevblocksPlatform::services()->template();
		
		// Conversational interactions
		$interactions = Event_GetInteractionsForMobileWorker::getInteractionsByPointAndWorker('mobile', [], $active_worker);
		$interactions_menu = Event_GetInteractionsForMobileWorker::getInteractionMenu($interactions);
		$tpl->assign('interactions_menu', $interactions_menu);
		
		$tpl->display('devblocks:cerberusweb.mobile::bots/index.tpl');
	}
	
	private function _renderBotChat($stack) {
		@$bot_id = array_shift($stack);
		@$interaction_behavior_id = array_shift($stack);
		@$interaction = DevblocksPlatform::importGPC($_REQUEST['interaction'], 'string', ''); 
		@$interaction_params = DevblocksPlatform::importGPC($_REQUEST['interaction_param'], 'array', []); 
		
		$active_worker = CerberusApplication::getActiveWorker();
		
		if(
			!$interaction_behavior_id
			|| false == ($interaction_behavior = DAO_TriggerEvent::get($interaction_behavior_id))
			|| $interaction_behavior->event_point != Event_NewInteractionChatMobileWorker::ID
		)
			return false;
		
		// Start the session using the behavior
		
		$actions = [];
		
		$client_ip = DevblocksPlatform::getClientIp();
		$client_platform = '';
		$client_browser = '';
		$client_browser_version = '';
		$client_url = @$browser['url'] ?: '';
		$client_time = @$browser['time'] ?: '';
		
		/*
		if(false !== ($client_user_agent_parts = DevblocksPlatform::getClientUserAgent())) {
			$client_platform = @$client_user_agent_parts['platform'] ?: '';
			$client_browser = @$client_user_agent_parts['browser'] ?: '';
			$client_browser_version = @$client_user_agent_parts['version'] ?: '';
		}
		*/
		
		$event_model = new Model_DevblocksEvent(
			Event_NewInteractionChatMobileWorker::ID,
			array(
				'worker' => $active_worker,
				'interaction' => $interaction,
				'interaction_params' => $interaction_params,
				'client_browser' => $client_browser,
				'client_browser_version' => $client_browser_version,
				'client_ip' => $client_ip,
				'client_platform' => $client_platform,
				'client_time' => $client_time,
				'client_url' => $client_url,
				'actions' => &$actions,
			)
		);
		
		if(false == ($event = $interaction_behavior->getEvent()))
			return;
		
		$event->setEvent($event_model, $interaction_behavior);
		
		$values = $event->getValues();
		
		$dict = DevblocksDictionaryDelegate::instance($values);
		
		$result = $interaction_behavior->runDecisionTree($dict, false, $event);
		
		$behavior_id = null;
		$bot_name = null;
		$dict = [];
		
		foreach($actions as $action) {
			switch($action['_action']) {
				case 'behavior.switch':
					if(isset($action['behavior_id'])) {
						@$behavior_id = $action['behavior_id'];
						@$variables = $action['behavior_variables'];
						
						if(is_array($variables))
						foreach($variables as $k => $v) {
							$dict[$k] = $v;
						}
					}
					break;
					
				case 'bot.name':
					if(false != (@$name = $action['name']))
						$bot_name = $name;
					break;
			}
		}
		
		if(
			!$behavior_id 
			|| false == ($behavior = DAO_TriggerEvent::get($behavior_id))
			|| $behavior->event_point != Event_NewMessageChatMobileWorker::ID
			)
			return;
			
		$bot = $behavior->getBot();
		
		if(empty($bot_name))
			$bot_name = $bot->name;
		
		$url_writer = DevblocksPlatform::services()->url();
		$bot_image_url = $url_writer->write(sprintf("c=avatars&w=bot&id=%d", $bot->id) . '?v=' . $bot->updated_at);
		
		$session_data = [
			'actor' => ['context' => CerberusContexts::CONTEXT_WORKER, 'id' => $active_worker->id],
			'bot_name' => $bot_name,
			'bot_image' => $bot_image_url,
			'behavior_id' => $behavior->id,
			'behaviors' => [
				$behavior->id => [
					'dict' => $dict,
				]
			],
			'interaction' => $interaction,
			'interaction_params' => $interaction_params,
			'client_browser' => $client_browser,
			'client_browser_version' => $client_browser_version,
			'client_ip' => $client_ip,
			'client_platform' => $client_platform,
			'client_time' => $client_time,
			'client_url' => $client_url,
		];
		
		$session_id = DAO_BotSession::create([
			DAO_BotSession::SESSION_DATA => json_encode($session_data),
			DAO_BotSession::UPDATED_AT => time(),
		]);
		
		$tpl = DevblocksPlatform::services()->template();
		
		$tpl->assign('bot', $bot);
		$tpl->assign('bot_name', $bot_name);
		$tpl->assign('bot_image_url', $bot_image_url);
		$tpl->assign('session_id', $session_id);
		
		$tpl->display('devblocks:cerberusweb.mobile::bots/chat.tpl');
	}
	
	function botSendMessageAction() {
		@$session_id = DevblocksPlatform::importGPC($_REQUEST['session_id'], 'string', '');
		@$message = DevblocksPlatform::importGPC($_REQUEST['message'], 'string', '');
		
		$active_worker = CerberusApplication::getActiveWorker();
		$tpl = DevblocksPlatform::services()->template();
		
		// Load the session
		if(false == ($interaction = DAO_BotSession::get($session_id)))
			return false;
		
		// [TODO] Verify session ownership
		// [TODO] What happens if we're chatting to a dead session? Open a new one?

		// Load our default behavior for this interaction
		if(false == (@$behavior_id = $interaction->session_data['behavior_id']))
			return false;
		
		if(false == ($behavior = DAO_TriggerEvent::get($behavior_id)))
			return;
		
		if(false == (@$bot_name = $interaction->session_data['bot_name']))
			$bot_name = 'Cerb';
		
		$actions = [];
		
		$event_params = [
			'worker_id' => $active_worker->id,
			'message' => $message,
			'actions' => &$actions,
				
			'bot_name' => $bot_name,
			'bot_image' => @$interaction->session_data['bot_image'],
			'behavior_id' => $behavior_id,
			'behavior_has_parent' => @$interaction->session_data['behavior_has_parent'],
			'interaction' => @$interaction->session_data['interaction'],
			'interaction_params' => @$interaction->session_data['interaction_params'],
			'client_browser' => @$interaction->session_data['client_browser'],
			'client_browser_version' => @$interaction->session_data['client_browser_version'],
			'client_ip' => @$interaction->session_data['client_ip'],
			'client_platform' => @$interaction->session_data['client_platform'],
			'client_time' => @$interaction->session_data['client_time'],
			'client_url' => @$interaction->session_data['client_url'],
		];
		
		$event_model = new Model_DevblocksEvent(
			Event_NewMessageChatMobileWorker::ID,
			$event_params
		);
		
		if(false == ($event = Extension_DevblocksEvent::get($event_model->id, true)))
			return;
		
		if(!($event instanceof Event_NewMessageChatMobileWorker))
			return;
			
		$event->setEvent($event_model, $behavior);
		
		$values = $event->getValues();
		
		// Are we resuming a scope?
		$resume_dict = @$interaction->session_data['behaviors'][$behavior->id]['dict'];
		if($resume_dict) {
			$values = array_replace($values, $resume_dict);
		}
		
		$dict = new DevblocksDictionaryDelegate($values);
			
		$resume_path = @$interaction->session_data['behaviors'][$behavior->id]['path'];
		
		if($resume_path) {
			$behavior->prepareResumeDecisionTree($message, $interaction, $actions, $dict, $resume_path);
			
			if(false == ($result = $behavior->resumeDecisionTree($dict, false, $event, $resume_path)))
				return;
			
		} else {
			if(false == ($result = $behavior->runDecisionTree($dict, false, $event)))
				return;
		}
		
		$values = $dict->getDictionary(null, false);
		$values = array_diff_key($values, $event->getValues());
		
		// Hibernate
		if($result['exit_state'] == 'SUSPEND') {
			// Keep everything as it is
		} else {
			// Start the tree over
			$result['path'] = [];
			
			// Return to the caller if we have one
			@$caller = array_pop($interaction->session_data['callers']);
			$interaction->session_data['behavior_has_parent'] = !empty($interaction->session_data['callers']) ? 1 : 0;
			
			if(is_array($caller)) {
				$caller_behavior_id = $caller['behavior_id'];
				
				if($caller_behavior_id && isset($interaction->session_data['behaviors'][$caller_behavior_id])) {
					$interaction->session_data['behavior_id'] = $caller_behavior_id;
					$interaction->session_data['behaviors'][$caller_behavior_id]['dict']['_behavior'] = $values;
				}
				
				$tpl->display('devblocks:cerberusweb.core::console/prompt_wait.tpl');
			}
		}
		
		$interaction->session_data['behaviors'][$behavior->id]['dict'] = $values;
		$interaction->session_data['behaviors'][$behavior->id]['path'] = $result['path'];
		
		if(false == ($bot = $behavior->getBot()))
			return;
		
		$tpl->assign('bot', $bot);
		$tpl->assign('bot_name', $bot_name);
		
		foreach($actions as $params) {
			// Are we handling the next response message in a special way?
			if(isset($params['_prompt']) && is_array($params['_prompt'])) {
				$interaction->session_data['_prompt'] = $params['_prompt'];
			}
			
			switch(@$params['_action']) {
				case 'behavior.switch':
					@$behavior_return = $params['behavior_return'];
					@$variables = $params['behavior_variables'];
					
					if(!isset($interaction->session_data['callers']))
						$interaction->session_data['callers'] = [];
					
					if($behavior_return) {
						$interaction->session_data['callers'][] = [
							'behavior_id' => $behavior->id,
							'return' => '_behavior', // [TODO] Configurable
						];
					} else {
						$interaction->session_data['behaviors'][$behavior->id]['dict'] = [];
						$interaction->session_data['behaviors'][$behavior->id]['path'] = [];
					}
					
					if(false == ($behavior_id = @$params['behavior_id']))
						break;
					
					if(false == ($new_behavior = DAO_TriggerEvent::get($behavior_id)))
						break;
					
					if($new_behavior->event_point != Event_NewMessageChatWorker::ID)
						break;
					
					if(!Context_TriggerEvent::isReadableByActor($new_behavior, $bot))
						break;
					
					$bot = $new_behavior->getBot();
					$tpl->assign('bot', $bot);
					
					$new_dict = [];
					
					if(is_array($variables))
					foreach($variables as $k => $v) {
						$new_dict[$k] = $v;
					}
					
					$interaction->session_data['behavior_id'] = $new_behavior->id;
					$interaction->session_data['behaviors'][$new_behavior->id]['dict'] = $new_dict;
					$interaction->session_data['behaviors'][$new_behavior->id]['path'] = [];
					
					if($behavior_return)
						$interaction->session_data['behavior_has_parent'] = 1;
					
					$tpl->assign('delay_ms', 0);
					$tpl->display('devblocks:cerberusweb.mobile::bots/prompts/prompt_wait.tpl');
					break;
					
				case 'emote':
					if(false == ($emote = @$params['emote']))
						break;
					
					$tpl->assign('emote', $emote);
					$tpl->assign('delay_ms', 500);
					$tpl->display('devblocks:cerberusweb.mobile::bots/responses/emote.tpl');
					break;
				
				case 'prompt.buttons':
					@$options = $params['options'];
					@$style = $params['style'];
					
					if(!is_array($options))
						break;
					
					$tpl->assign('options', $options);
					$tpl->assign('style', $style);
					$tpl->assign('delay_ms', 0);
					$tpl->display('devblocks:cerberusweb.mobile::bots/prompts/prompt_buttons.tpl');
					break;
					
				case 'prompt.images':
					@$images = $params['images'];
					@$labels = $params['labels'];
					
					if(!is_array($images) || !is_array($images))
						break;
					
					$tpl->assign('images', $images);
					$tpl->assign('labels', $labels);
					$tpl->assign('delay_ms', 0);
					$tpl->display('devblocks:cerberusweb.mobile::bots/prompts/prompt_images.tpl');
					break;
					
				case 'prompt.text':
					@$placeholder = $params['placeholder'];
					@$default = $params['default'];
					@$mode = $params['mode'];
					
					if(empty($placeholder))
						$placeholder = 'say something';
					
					$tpl->assign('delay_ms', 0);
					$tpl->assign('placeholder', $placeholder);
					$tpl->assign('default', $default);
					$tpl->assign('mode', $mode);
					$tpl->display('devblocks:cerberusweb.mobile::bots/prompts/prompt_text.tpl');
					break;
					
				case 'prompt.wait':
					$tpl->assign('delay_ms', 0);
					$tpl->display('devblocks:cerberusweb.mobile::bots/prompts/prompt_wait.tpl');
					break;
					
				case 'message.send':
					if(false == ($msg = @$params['message']))
						break;
					
					$delay_ms = DevblocksPlatform::intClamp(@$params['delay_ms'], 0, 10000);
					
					$tpl->assign('message', $msg);
					$tpl->assign('format', @$params['format']);
					$tpl->assign('delay_ms', $delay_ms);
					$tpl->display('devblocks:cerberusweb.mobile::bots/responses/message.tpl');
					break;
					
				case 'script.send':
					if(false == ($script = @$params['script']))
						break;
						
					$tpl->assign('script', $script);
					$tpl->assign('delay_ms', 0);
					$tpl->display('devblocks:cerberusweb.mobile::bots/responses/script.tpl');
					break;
			}
		}
		
		// Save session scope
		DAO_BotSession::update($interaction->session_id, [
			DAO_BotSession::SESSION_DATA => json_encode($interaction->session_data),
			DAO_BotSession::UPDATED_AT => time(),
		]);
	}
};