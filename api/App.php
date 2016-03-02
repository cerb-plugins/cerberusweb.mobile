<?php
if (class_exists('Extension_AppPreBodyRenderer',true)):
	class MobilePreBodyRenderer extends Extension_AppPreBodyRenderer {
		function render() {
			$tpl = DevblocksPlatform::getTemplateService();
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
		$tpl = DevblocksPlatform::getTemplateService();
		$translate = DevblocksPlatform::getTranslationService();
		$settings = DevblocksPlatform::getPluginSettingsService();
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
				
			case 'va':
				@$request = array_shift($stack);
				
				if(is_numeric($request)) {
					array_unshift($stack, $request);
					$this->_renderVirtualAttendantBehaviors($stack);
					return;
				}
				
				switch($request) {
					case 'behavior':
						$this->_renderVirtualAttendantBehavior($stack);
						break;
					
					case 'run':
						$this->_renderVirtualAttendantBehaviorResults($stack);
						break;
					
					default:
						$this->_renderVirtualAttendants($stack);
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
		
		$tpl = DevblocksPlatform::getTemplateService();
		
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
		
		$tpl = DevblocksPlatform::getTemplateService();

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
	
	function showProfileVaBehaviorMenuAction() {
		@$context = DevblocksPlatform::importGPC($_REQUEST['context'], 'string', '');
		@$context_id = DevblocksPlatform::importGPC($_REQUEST['context_id'], 'integer', 0);
		
		$active_worker = CerberusApplication::getActiveWorker();
		$tpl = DevblocksPlatform::getTemplateService();
		
		$tpl->assign('context', $context);
		$tpl->assign('context_id', $context_id);
		
		$events = Extension_DevblocksEvent::getAll();
		
		$events = array_filter($events, function($event) use ($context) {
			@$event_context = $event->params['macro_context'];
			return ($event_context == $context);
		});
		
		$macros = array();
		
		foreach($events as $event) {
			$macros += DAO_TriggerEvent::getReadableByActor($active_worker, $event->id, false);
		}
		
		$tpl->assign('macros', $macros);

		$vas = DAO_VirtualAttendant::getAll();
		$tpl->assign('vas', $vas);
		
		// Template
		
		$tpl->display('devblocks:cerberusweb.mobile::profiles/va_macros.tpl');
		exit;
	}
	
	function showVaBehaviorDialogAction() {
		@$behavior_id = DevblocksPlatform::importGPC($_REQUEST['behavior_id'], 'integer', 0);
		@$context = DevblocksPlatform::importGPC($_REQUEST['context'], 'string', '');
		@$context_id = DevblocksPlatform::importGPC($_REQUEST['context_id'], 'integer', 0);
		
		$active_worker = CerberusApplication::getActiveWorker();
		$tpl = DevblocksPlatform::getTemplateService();
		
		$tpl->assign('context', $context);
		$tpl->assign('context_id', $context_id);
		
		if(null == ($behavior = DAO_TriggerEvent::get($behavior_id)))
			return;
		
		if(null == ($va = $behavior->getVirtualAttendant()))
			return;
		
		if(!$va->isReadableByActor($active_worker))
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
		
		if(null == ($va = $behavior->getVirtualAttendant()))
			return;
		
		if(!$va->isReadableByActor($active_worker))
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
		
		$tpl = DevblocksPlatform::getTemplateService();
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
		
		$tpl = DevblocksPlatform::getTemplateService();
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
		
		$tpl = DevblocksPlatform::getTemplateService();
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
		
		$tpl = DevblocksPlatform::getTemplateService();
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
		
		$tpl = DevblocksPlatform::getTemplateService();
		$tpl->assign('view', $view);
		$tpl->assign('hide_filtering', $hide_filtering);
		$tpl->assign('hide_sorting', $hide_sorting);
		$tpl->display('devblocks:cerberusweb.mobile::workspaces/worklist_view.tpl');
		exit;
	}
	
	private function _renderCompose($stack) {
		$active_worker = CerberusApplication::getActiveWorker();
		$tpl = DevblocksPlatform::getTemplateService();
		
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
		$tpl = DevblocksPlatform::getTemplateService();
		
		$worker_prefs = DAO_WorkerPref::getByWorker($active_worker->id);
		$tpl->assign('worker_prefs', $worker_prefs);
		
		$tpl->display('devblocks:cerberusweb.mobile::settings/index.tpl');
	}
	
	private function _renderNotifications($stack) {
		$active_worker = CerberusApplication::getActiveWorker();
		
		$tpl = DevblocksPlatform::getTemplateService();
		
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
		
		$tpl = DevblocksPlatform::getTemplateService();
		
		$tpl->assign('page_title', 'Pages');
		
		$workspaces = DAO_WorkspacePage::getByWorker($active_worker);
		$tpl->assign('workspaces', $workspaces);
		
		$tpl->display('devblocks:cerberusweb.mobile::workspaces/index.tpl');
	}
	
	private function _renderProfile($stack) {
		@$context = array_shift($stack);
		@$context_id = intval(array_shift($stack));

		$active_worker = CerberusApplication::getActiveWorker();
		$tpl = DevblocksPlatform::getTemplateService();
		
		if(false == ($context_ext = Extension_DevblocksContext::get($context)))
			return;
		
		if(false == $context_ext->authorize($context_id, $active_worker))
			return;
		
		$tpl->assign('context', $context);
		$tpl->assign('context_ext', $context_ext);
		$tpl->assign('context_id', $context_id);
		
		CerberusContexts::getContext($context, $context_id, $labels, $values, null, true);

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
		
		// VAs
		
		$events = Extension_DevblocksEvent::getAll();
		
		$events = array_filter($events, function($event) use ($context) {
			@$event_context = $event->params['macro_context'];
			return ($event_context == $context);
		});
		
		$macros = array();
		
		foreach($events as $event) {
			$macros += DAO_TriggerEvent::getReadableByActor($active_worker, $event->id, false);
		}
		
		$tpl->assign('macros', $macros);
		
		$tpl->display('devblocks:cerberusweb.mobile::profiles/profile.tpl');
	}
	
	private function _renderSearch($stack) {
		$active_worker = CerberusApplication::getActiveWorker();
		
		$tpl = DevblocksPlatform::getTemplateService();
		
		$contexts = Extension_DevblocksContext::getAll(false, array('workspace'));
		$tpl->assign('contexts', $contexts);
		
		$tpl->display('devblocks:cerberusweb.mobile::search/index.tpl');
	}
	
	private function _renderSearchWorklist($stack) {
		@$context_ext_id = array_shift($stack);
		
		if(empty($context_ext_id))
			return false;
		
		if(false == ($context_ext = Extension_DevblocksContext::get($context_ext_id)))
			return false;
		
		$active_worker = CerberusApplication::getActiveWorker();
		
		$tpl = DevblocksPlatform::getTemplateService();

		$tpl->assign('context_ext', $context_ext);
		
		$view = $context_ext->getSearchView();
		
		$view->renderLimit = 10;
		$view->renderTotal = true;
		
		$tpl->assign('view', $view);
		
		$tpl->display('devblocks:cerberusweb.mobile::search/worklist.tpl');
	}
	
	private function _renderWorkspaces($stack) {
		$active_worker = CerberusApplication::getActiveWorker();
		
		$tpl = DevblocksPlatform::getTemplateService();
		
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
		$tpl = DevblocksPlatform::getTemplateService();
		
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
		$tpl = DevblocksPlatform::getTemplateService();
		
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
		$tpl = DevblocksPlatform::getTemplateService();
		
		$worklist = DAO_WorkspaceList::get($workspace_list_id);

		$view_id = 'cust_' . $worklist->id;
		
		// Make sure our workspace source has a valid renderer class
		if(null == ($ext = DevblocksPlatform::getExtension($worklist->context, true))) { /* @var $ext Extension_DevblocksContext */
			return;
		}
		
		if(null == ($view = C4_AbstractViewLoader::getView($view_id))) {
			$list_view = $worklist->list_view; /* @var $list_view Model_WorkspaceListView */
				
			$view = $ext->getChooserView($view_id);  /* @var $view C4_AbstractView */
				
			if(empty($view))
				return;
				
			$view->name = $list_view->title;
			$view->renderLimit = $list_view->num_rows;
			$view->renderPage = 0;
			$view->is_ephemeral = 0;
			$view->view_columns = $list_view->columns;
			$view->addParams($list_view->params, true);
			if(property_exists($list_view, 'params_required'))
				$view->addParamsRequired($list_view->params_required, true);
			$view->renderSortBy = $list_view->sort_by;
			$view->renderSortAsc = $list_view->sort_asc;
			$view->renderSubtotals = $list_view->subtotals;
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
		$tpl = DevblocksPlatform::getTemplateService();
		
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
	
	/* Virtual Attendants */
	
	private function _renderVirtualAttendants($stack) {
		$active_worker = CerberusApplication::getActiveWorker();
		
		$tpl = DevblocksPlatform::getTemplateService();
		
		$vas = DAO_VirtualAttendant::getReadableByActor($active_worker);
		
		// Only show VAs with mobile behaviors
		$vas = array_filter($vas, function($va) {
			$behaviors = $va->getBehaviors(Event_MobileBehavior::ID, false, 'name');
			return !empty($behaviors);
		});
		
		$tpl->assign('vas', $vas);
		
		$tpl->display('devblocks:cerberusweb.mobile::virtual_attendants/index.tpl');
	}
	
	private function _renderVirtualAttendantBehaviors($stack) {
		@$va_id = array_shift($stack);

		$active_worker = CerberusApplication::getActiveWorker();
		$tpl = DevblocksPlatform::getTemplateService();

		$va = DAO_VirtualAttendant::get($va_id);
		
		if(!$va->isReadableByActor($active_worker))
			return;
		
		$tpl->assign('va', $va);
		
		$behaviors = $va->getBehaviors(Event_MobileBehavior::ID, false, 'name');
		$tpl->assign('behaviors', $behaviors);
		
		$tpl->display('devblocks:cerberusweb.mobile::virtual_attendants/behaviors.tpl');
	}
	
	private function _renderVirtualAttendantBehavior($stack) {
		@$behavior_id = array_shift($stack);

		$active_worker = CerberusApplication::getActiveWorker();
		$tpl = DevblocksPlatform::getTemplateService();
		
		if(null == ($behavior = DAO_TriggerEvent::get($behavior_id)))
			return;
		
		if(null == ($va = $behavior->getVirtualAttendant()))
			return;
		
		if(!$va->isReadableByActor($active_worker))
			return;
		
		$tpl->assign('va', $va);
		$tpl->assign('behavior', $behavior);
		
		$tpl->display('devblocks:cerberusweb.mobile::virtual_attendants/behavior.tpl');
	}
	
	private function _renderVirtualAttendantBehaviorResults($stack) {
		@$behavior_id = array_shift($stack);

		$active_worker = CerberusApplication::getActiveWorker();
		$tpl = DevblocksPlatform::getTemplateService();
		
		if(null == ($behavior = DAO_TriggerEvent::get($behavior_id)))
			return;
		
		if(null == ($va = $behavior->getVirtualAttendant()))
			return;
		
		if(!$va->isReadableByActor($active_worker))
			return;
		
		if($va->is_disabled)
			return false;
		
		if($behavior->is_disabled)
			return false;
		
		$tpl->assign('va', $va);
		$tpl->assign('behavior', $behavior);
		
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
					//if(!isset($_REQUEST[$var_key]))
						//return false;
						//$this->error(self::ERRNO_CUSTOM, $e->getMessage());
					
				}
				
				$vars[$var_key] = $var_val;
			}
		}
		
		// [TODO] Verify the trigger is a mobile behavior (event.api.mobile_behavior)
		
		// Load event manifest
		if(null == ($ext = DevblocksPlatform::getExtension($behavior->event_point, false))) /* @var $ext DevblocksExtensionManifest */
			return false;
			//$this->error(self::ERRNO_CUSTOM);
		
		// Trigger a mobile behavior
		$runners = call_user_func(array($ext->class, 'trigger'), $behavior->id, $active_worker->id, $vars);
		
		$values = array();
		
		if(null != (@$runner = $runners[$behavior->id])) {
			// Return the whole scope of the behavior to the caller
			// [TODO] Does this need _labels and _types?
			$values = $runner->getDictionary();
			//@$message = $runner->_output ?: ''; /* @var $runner DevblocksDictionaryDelegate */
		}

		$dict = new DevblocksDictionaryDelegate($values);
		$tpl->assign('dict', $dict);
		
		$responses = $dict->_responses;
		$tpl->assign('responses', $responses);
		
		$tpl->display('devblocks:cerberusweb.mobile::virtual_attendants/behavior_results.tpl');
	}
};