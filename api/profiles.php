<?php
abstract class Extension_MobileProfileBlock extends DevblocksExtension {
	static function getAll($as_instances=false, $with_contexts=null) {
		if(!is_null($with_contexts) && !is_array($with_contexts))
			$with_contexts = array($with_contexts);
		
		$extensions = DevblocksPlatform::getExtensions('mobile.profile.block', true);
		
		if(is_array($with_contexts))
		foreach($extensions as $extension_id => $extension) {
			$allowed_contexts = array();
			
			if($as_instances) {
				$allowed_contexts = array_keys($extension->manifest->params['contexts'][0]);
			} else {
				$allowed_contexts = array_keys($extension->params['contexts'][0]);
			}
			
			foreach($with_contexts as $context) {
				if(!in_array($context, $allowed_contexts)) {
					unset($extensions[$extension_id]);
					continue;
				}
			}
		}
		
		return $extensions;
	}
	
	/**
	 * @param unknown_type $context
	 * @return Extension_DevblocksContext
	 */
	public static function get($id) {
		static $extensions = null;
		
		if(isset($extensions[$id]))
			return $extensions[$id];
		
		if(!isset($extensions[$id])) {
			if(null == ($ext = DevblocksPlatform::getExtension($id, true)))
				return;
			
			if(!($ext instanceof Extension_MobileProfileBlock))
				return;
			
			$extensions[$id] = $ext;
			return $ext;
		}
	}
	
	abstract function render(DevblocksDictionaryDelegate $dict);
};

if(class_exists('Extension_MobileProfileBlock')):
class MobileProfile_Task extends Extension_MobileProfileBlock {
	const ID = 'mobile.profile.block.task';
	
	function render(DevblocksDictionaryDelegate $dict) {
		$tpl = DevblocksPlatform::getTemplateService();
		$tpl->assign('dict', $dict);
		$tpl->display('devblocks:cerberusweb.mobile::profiles/blocks/task.tpl');
	}
	
	function showEditDialogAction() {
		@$id  = DevblocksPlatform::importGPC($_REQUEST['id'], 'integer', 0);
		
		$tpl = DevblocksPlatform::getTemplateService();
		
		$active_worker = CerberusApplication::getActiveWorker();
		$tpl->assign('active_worker', $active_worker);

		CerberusContexts::getContext(CerberusContexts::CONTEXT_TASK, $id, $null, $values);
		
		$dict = new DevblocksDictionaryDelegate($values);
		$tpl->assign('dict', $dict);
		
		// Template
		
		$tpl->display('devblocks:cerberusweb.mobile::profiles/blocks/task/edit_dialog.tpl');
		exit;
	}
	
	function saveEditDialogAction() {
		@$id = DevblocksPlatform::importGPC($_REQUEST['id'], 'integer', 0);
		@$title = DevblocksPlatform::importGPC($_REQUEST['title'], 'string', '');
		@$status = DevblocksPlatform::importGPC($_REQUEST['status'], 'string', '');
		@$due_date = DevblocksPlatform::importGPC($_REQUEST['due_date'], 'string', '');
		
		$active_worker = CerberusApplication::getActiveWorker();
		
		$fields = array();
		
		// Title
		
		if(!empty($title))
			$fields[DAO_Task::TITLE] = $title;
		
		// Status
		
		switch($status) {
			case 'active':
				$fields[DAO_Task::IS_COMPLETED] = 0;
				$fields[DAO_Task::COMPLETED_DATE] = 0;
				break;
				
			case 'completed':
				$fields[DAO_Task::IS_COMPLETED] = 1;
				$fields[DAO_Task::COMPLETED_DATE] = time();
				break;
		}
		
		// Due date
		
		$fields[DAO_Task::DUE_DATE] = intval(@strtotime($due_date));
		
		// DAO
		
		DAO_Task::update($id, $fields);

		header('Content-type: application/json');
		
		echo json_encode(array(
			'success' => true,
		));
		
		exit;
	}
	
};

class MobileProfile_Ticket extends Extension_MobileProfileBlock {
	const ID = 'mobile.profile.block.ticket';
	
	function render(DevblocksDictionaryDelegate $dict) {
		$tpl = DevblocksPlatform::getTemplateService();
		$tpl->assign('dict', $dict);
		
		/*
		// Show ticket messages
		$defaults = new C4_AbstractViewModel();
		$defaults->id = '';
		$defaults->class_name = 'View_Message';
		$defaults->is_ephemeral = true;
		
		if(false != ($view = C4_AbstractViewLoader::getView('mobile_profile_ticket_messages', $defaults))) {
			$view->addParamsRequired(array(
				new DevblocksSearchCriteria(SearchFields_Message::TICKET_ID, '=', $dict->id)
			), true);
			
			$view->renderSortBy = SearchFields_Message::CREATED_DATE;
			$view->renderSortAsc = false;
			$view->renderPage = 0;
			$view->renderLimit = 10;
			$view->renderTotal = true;
			
			// [TODO] Overload the default properties for the messages worklist (e.g. no need to see ticket listed every time)
			
			C4_AbstractViewLoader::setView($view->id, $view);
			
			$tpl->assign('view', $view);
		}
		*/
		
		$tpl->display('devblocks:cerberusweb.mobile::profiles/blocks/ticket.tpl');
	}
	
	function showEditDialogAction() {
		@$id  = DevblocksPlatform::importGPC($_REQUEST['id'], 'integer', 0);
		
		$tpl = DevblocksPlatform::getTemplateService();
		
		$active_worker = CerberusApplication::getActiveWorker();
		$tpl->assign('active_worker', $active_worker);

		CerberusContexts::getContext(CerberusContexts::CONTEXT_TICKET, $id, $null, $values);
		
		$dict = new DevblocksDictionaryDelegate($values);
		$tpl->assign('dict', $dict);
		
		// Template
		
		$tpl->display('devblocks:cerberusweb.mobile::profiles/blocks/ticket/edit_dialog.tpl');
		exit;
	}
	
	function saveEditDialogAction() {
		@$id = DevblocksPlatform::importGPC($_REQUEST['id'], 'integer', 0);
		@$reopen_at = DevblocksPlatform::importGPC($_REQUEST['reopen_at'], 'string', '');
		@$status = DevblocksPlatform::importGPC($_REQUEST['status'], 'string', '');
		@$owner_id = DevblocksPlatform::importGPC($_REQUEST['owner_id'], 'integer', 0);
		@$spam_training = DevblocksPlatform::importGPC($_REQUEST['spam_training'], 'string', '');
		
		$active_worker = CerberusApplication::getActiveWorker();
		
		$fields = array();
		
		// [TODO] Check permissions
		if($status == 'deleted') {
			$fields[DAO_Ticket::IS_WAITING] = 0;
			$fields[DAO_Ticket::IS_CLOSED] = 1;
			$fields[DAO_Ticket::IS_DELETED] = 1;
			$fields[DAO_Ticket::REOPEN_AT] = 0;
			
		} else {
			// Spam training
			if(!empty($spam_training)) {
				if($spam_training == 'S')
					CerberusBayes::markTicketAsSpam($id);
				elseif($spam_training == 'N')
					CerberusBayes::markTicketAsNotSpam($id);
			}
			
			// Owner
			$fields[DAO_Ticket::OWNER_ID] = $owner_id;
			
			// Status
			switch($status) {
				case 'open':
					$fields[DAO_Ticket::IS_WAITING] = 0;
					$fields[DAO_Ticket::IS_CLOSED] = 0;
					$fields[DAO_Ticket::IS_DELETED] = 0;
					$fields[DAO_Ticket::REOPEN_AT] = 0;
					break;
					
				case 'waiting':
					$fields[DAO_Ticket::IS_WAITING] = 1;
					$fields[DAO_Ticket::IS_CLOSED] = 0;
					$fields[DAO_Ticket::IS_DELETED] = 0;
					$fields[DAO_Ticket::REOPEN_AT] = intval(@strtotime($reopen_at));
					break;
					
				case 'closed':
					$fields[DAO_Ticket::IS_WAITING] = 0;
					$fields[DAO_Ticket::IS_CLOSED] = 1;
					$fields[DAO_Ticket::IS_DELETED] = 0;
					$fields[DAO_Ticket::REOPEN_AT] = intval(@strtotime($reopen_at));
					break;
			}
		}
		
		DAO_Ticket::update($id, $fields);

		header('Content-type: application/json');
		
		echo json_encode(array(
			'success' => true,
		));
		
		exit;
	}
	
	function showReplyDialogAction() {
		@$message_id  = DevblocksPlatform::importGPC($_REQUEST['message_id'], 'integer', 0);
		
		$tpl = DevblocksPlatform::getTemplateService();
		
		$active_worker = CerberusApplication::getActiveWorker();
		$tpl->assign('active_worker', $active_worker);

		CerberusContexts::getContext(CerberusContexts::CONTEXT_MESSAGE, $message_id, $null, $values);
		
		$dict = new DevblocksDictionaryDelegate($values);
		$tpl->assign('dict', $dict);
		
		// Template
		
		$tpl->display('devblocks:cerberusweb.mobile::profiles/blocks/ticket/reply_dialog.tpl');
		exit;
	}
	
	function saveReplyDialogAction() {
		@$message_id = DevblocksPlatform::importGPC($_REQUEST['reply_to_message_id'], 'integer', 0);
		@$content = DevblocksPlatform::importGPC($_REQUEST['content'], 'string', '');
		@$reopen_at = DevblocksPlatform::importGPC($_REQUEST['reopen_at'], 'string', '');
		@$status = DevblocksPlatform::importGPC($_REQUEST['status'], 'string', '');
		
		$active_worker = CerberusApplication::getActiveWorker();
		
		$new_message_id = CerberusMail::sendTicketMessage(array(
			'message_id' => $message_id,
			'closed' => array_search($status, array('open','closed','waiting')),
			'ticket_reopen' => ($status != 'open') ? $reopen_at : 0,
			'content' => $content,
			'worker_id' => $active_worker->id,
		));
		
		$message = DAO_Message::get($new_message_id);
		
		header('Content-type: application/json');
		
		echo json_encode(array(
			'success' => true,
			'message_id' => $message->id,
			'ticket_id' => $message->ticket_id,
		));
		
		exit;
	}
	
	function viewSearchMessagesAction() {
		@$ticket_id = DevblocksPlatform::importGPC($_REQUEST['ticket_id'], 'integer', 0);
		
		$ticket = DAO_Ticket::get($ticket_id);
		
		$context_ext = Extension_DevblocksContext::get(CerberusContexts::CONTEXT_MESSAGE);
		$view = $context_ext->getSearchView(); /* @var $view C4_AbstractView */
		$view->addParams(array(
			new DevblocksSearchCriteria(SearchFields_Message::TICKET_MASK, '=', $ticket->mask)
		), true);
		
		C4_AbstractViewLoader::setView($view->id, $view);
	}
	
	function getMessageAction() {
		@$id = DevblocksPlatform::importGPC($_REQUEST['id'], 'integer', 0);
		
		$tpl = DevblocksPlatform::getTemplateService();
		
		CerberusContexts::getContext(CerberusContexts::CONTEXT_MESSAGE, $id, $labels, $values);
		$dict = new DevblocksDictionaryDelegate($values);
		
		$tpl->assign('dict', $dict);
		
		$tpl->display('devblocks:cerberusweb.mobile::profiles/blocks/ticket/message.tpl');
		exit;
	}
	
};
endif;