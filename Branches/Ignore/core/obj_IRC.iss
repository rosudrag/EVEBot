objectdef obj_IRC inherits obj_BaseClass
{
	variable string SVN_REVISION = "$Rev$"

	variable bool IsConnected = FALSE
	variable queue:string Buffer


	method Initialize()
	{
#if USE_ISXIM
		LogPrefix:Set["${This.ObjectName}"]
		ext -require ISXIM

		Event[IRC_ReceivedNotice]:AttachAtom[This:IRC_ReceivedNotice]
		Event[IRC_ReceivedChannelMsg]:AttachAtom[This:IRC_ReceivedChannelMsg]
		Event[IRC_ReceivedPrivateMsg]:AttachAtom[This:IRC_ReceivedPrivateMsg]
		Event[IRC_KickedFromChannel]:AttachAtom[This:IRC_KickedFromChannel]
		Event[IRC_PRIVMSGErrorResponse]:AttachAtom[This:IRC_PRIVMSGErrorResponse]
		Event[IRC_JOINErrorResponse]:AttachAtom[This:IRC_JOINErrorResponse]
		Event[IRC_UnhandledEvent]:AttachAtom[This:IRC_UnhandledEvent]

		PulseTimer:SetIntervals[1.0,1.0]
		Event[EVENT_ONFRAME]:AttachAtom[This:Pulse]
		Logger:Log["${LogPrefix}: Initialized", LOG_MINOR]
#endif
	}

	method Shutdown()
	{
#if USE_ISXIM
		Event[EVENT_ONFRAME]:DetachAtom[This:Pulse]

		Event[IRC_ReceivedNotice]:DetachAtom[This:IRC_ReceivedNotice]
		Event[IRC_ReceivedChannelMsg]:DetachAtom[This:IRC_ReceivedChannelMsg]
		Event[IRC_ReceivedPrivateMsg]:DetachAtom[This:IRC_ReceivedPrivateMsg]
		Event[IRC_KickedFromChannel]:DetachAtom[This:IRC_KickedFromChannel]
		Event[IRC_PRIVMSGErrorResponse]:DetachAtom[This:IRC_PRIVMSGErrorResponse]
		Event[IRC_JOINErrorResponse]:DetachAtom[This:IRC_JOINErrorResponse]
		Event[IRC_UnhandledEvent]:DetachAtom[This:IRC_UnhandledEvent]

		if ${This.IsConnected}
		{
			IRCUser[${Config.Common.IRCUser}]:Disconnect
		}
#endif
	}

	method Pulse()
	{
		if !${EVEBot.Loaded} || ${EVEBot.Disabled}
		{
			return
		}

		if ${This.PulseTimer.Ready}
		{
			if ${This.IsConnected}
			{
				if ${This.Buffer.Peek(exists)}
				{
					This:SendMessage["${This.Buffer.Peek}"]
					This.Buffer:Dequeue
				}
			}

			This.PulseTimer:Update
		}
	}

	method IRC_ReceivedNotice(string User, string From, string To, string Message)
	{
		; This event is fired every time that an IRCUser that you have connected
		; receives a NOTICE.  You can do anything fancy you want with this, but,
		; for now, we're just going to echo it to the console window.

		; Deal with Nickserv:
		if (${From.Equal[Nickserv]})
		{
			if (${Message.Find[This nickname is registered and protected]})
			{
				; Send the password to Nickserv.  You might want to do this
				; more elegantly by saving passwords in the script via variables or XML
				if (${To.Equal[${Config.Common.IRCUser}]})
				{
					IRCUser[${Config.Common.IRCUser}]:PM[Nickserv,"identify ${Config.Common.IRCPassword}"]
				}
				return
			}
			elseif (${Message.Find[Password accepted]})
			{
				echo "[${To.Escape}] Identify with Nickserv successful"

				; if this was an attempt to register the nick after having been
				; denied access to a channel, we want to indicate that it was
				; successful by resetting the number of attempts to zero
				if (${RegisteredChannelRetryAttempts} > 0)
				{
					RegisteredChannelRetryAttempts:Set[0]
				}
				return
			}
			elseif (${Message.Find[Password incorrect]})
			{
				echo "Incorrect password while attempting to identify ${To.Escape} with Nickserv"
				return
			}
			elseif (${Message.Find[Password authentication required]})
			{
				echo "Password authentication is required before you can issue commands to Nickserv"
				return
			}
			elseif (${Message.Find[nick, type]})
			{
				; Junk message we don't need to see
				return
			}
			elseif (${Message.Find[please choose a different]})
			{
				; Junk message we don't need to see
				return
			}
		}

		if (${Message.Find[DCC Send]})
		{
			; This is handled by the CTCP event -- I'm not sure why clients send both
			; a NOTICE and a CTCP when they're dcc'ing files
			return
		}
		  elseif (${Message.Find[DCC Chat]})
		{
			; This is handled by the CTCP event -- I'm not sure why clients send both
			; a NOTICE and a CTCP when they're dcc'ing files
			return
		}

		echo "[${User.Escape}] ${To.Escape} just received a NOTICE from ${From.Escape} :: ${Message.Escape}"
	}

	method IRC_ReceivedChannelMsg(string User, string Channel, string From, string Message)
	{
		; This event is fired every time that an IRCUser that you have connected
		; receives a Channel Message.  You can do anything fancy you want with this,
		; but, for now, we're just going to echo it to the console window.

		echo "[${User.Escape} - ${Channel.Escape}] -- (${From.Escape}) ${Message.Escape}"
	}

	method IRC_ReceivedPrivateMsg(string User, string From, string To, string Message)
	{
		; This event is fired every time that an IRCUser that you have connected
		; receives a Private Message.  You can do anything fancy you want with this,
		; but, for now, we're just going to echo it to the console window.

		; NOTE: ${User} should always be the same as ${To} in this instance.  However, it is
		; included for continuity's sake.

		echo "[Private Message -> ${To.Escape}] (${From.Escape}) ${Message.Escape}"
	}

	method IRC_KickedFromChannel(string User, string Channel, string WhoKicked, string KickedBy, string Reason)
	{
		; This event is fired every time that one of your IRCUsers are kicked from a
		; channel.  You can do anything fancy you want to do with this, but, for now, we're
		; just going to echo the information to the console window

		echo "[${User.Escape}] ${WhoKicked} has been KICKED from ${Channel.Escape}!"
		echo "Reason: "${Reason.Escape}" (by ${KickedBy.Escape})"

		; Auto rejoin! :)
		IRCUser[${WhoKicked}]:Join[${Channel.Escape}]
	}

	method IRC_PRIVMSGErrorResponse(string User, string ErrorType, string To, string Response)
	{
		; This event is fired whenever an IRCUser that you have connected receives an
		; error response while trying to send a PM.
		; NOTE: The IRC protocol considers a message sent to a channel to be a "PM" to
		; that channel.

		; Possible ${ErrorType} include: "NO_SUCH_NICKORCHANNEL", "NO_EXTERNAL_MSGS_ALLOWED"

		if (${ErrorType.Equal[NO_SUCH_NICKORCHANNEL]})
		{
			echo "[${User.Escape}] Sorry, '${To.Escape}' does not exist."
			return
		}
		elseif (${ErrorType.Equal[NO_EXTERNAL_MSGS_ALLOWED]})
		{
			echo "[${User.Escape}] Sorry, ${To.Escape} does not allow for external messages."
			echo "[${User.Escape}] You will need to join ${To.Escape} in order to send messages to the channel."
			return
		}
	}

	method IRC_JOINErrorResponse(string User, string ErrorType, string Channel, string Response)
	{
		; This event is fired whenever an IRCUser that you have connected receives an
		; error response while trying to join a channel.

		; Possible ${ErrorType} include: "BANNED", "MUST_BE_REGISTERED"

		if (${ErrorType.Equal[BANNED]})
		{
			echo "[${User.Escape}] Sorry, you have been banned from ${Channel.Escape}!"
			return
		}
		elseif (${ErrorType.Equal[REQUIRES_KEY]})
		{
			echo "[${User.Escape}] Sorry, this channel requires a password."
			return
		}
		elseif (${ErrorType.Equal[MUST_BE_REGISTERED]})
		{
			echo "[${User.Escape}] Received a message that we were not identified/registered."

			; We will try and identify with nickserv and rejoin a total of 5 times before giving up.
			; This is necessary because sometimes the script will try and join a registered channel
			; before nickserv has a chance to acknowledge identification.  Again, this method is
			; not very elegant because the passwords are hardcoded; however, it proves the point.
			if (${RegisteredChannelRetryAttempts} <= 5)
			{
				echo "[${User.Escape}] Identifying with Nickserv now."
				if (${UserName.Equal[${Config.Common.IRCUser}]})
				{
					IRCUser[${Config.Common.IRCUser}]:PM[Nickserv,"identify ${Config.Common.IRCPassword}"]
				}
				IRCUser[${User}]:Join[${Channel}]
				RegisteredChannelRetryAttempts:Inc
				return
			}
		}
	}

	method IRC_UnhandledEvent(string User, string Command, string Param, string Rest)
	{
		; This event is here to handle any events that are not handled otherwise by the
		; the extension.  There will probably be a lot of spam here, so you won't want to
		; echo everything.  The best thing to do is only use this event when there is something
		; that is happening with the client that you want added as a feature to isxIM and need
		; the data to tell Amadeus.

		; However, we do want any ERROR messages!
		if (${Command.Equal[ERROR]})
		{
			echo "CRITICAL IRC ERROR: ${Rest.Escape}"
		}
	}

	member:bool Connected()
	{
		if ${IRC.NumUsers} > 0
		{
			return TRUE
		}

		return FALSE
	}

	function Connect()
	{
	#if USE_ISXIM
		Logger:Log["${This.LogPrefix}: Connecting to IRC", LOG_ECHOTOO]
	#else
		return
	#endif

		IRC:Connect[${Config.Common.IRCServer},${Config.Common.IRCUser}]

		wait 10

		if (${IRCUser[${Config.Common.IRCUser}](exists)} && ${IRCUser[${Config.Common.IRCUser}].IsConnected})
		{
			IRCUser[${Config.Common.IRCUser}]:Join[${Config.Common.IRCChannel}]
			wait 5
			This.IsConnected:Set[TRUE]
			Call This.Say "${AppVersion} Connected"
		}
	}

	function Disconnect()
	{
		if ${This.IsConnected}
		{
			echo DEBUG: Disconnecting...
			Call This.Say "Disconnecting"
			wait 5

			IRCUser[${Config.Common.IRCUser}]:Disconnect
			This.IsConnected:Set[FALSE]
		}
	}

	method QueueMessage(string msg)
	{
#if USE_ISXIM
		This.Buffer:Queue["${msg}"]
#endif
	}

	; This should not be called by users of this object.
	method SendMessage(string msg)
	{
		if ${This.IsConnected}
		{
			IRCUser[${Config.Common.IRCUser}].Channel[${Config.Common.IRCChannel}]:Say["${msg}"]
		}
	}

	function Say(string msg)
	{
		This:QueueMessage["${msg}"]
		if !${This.IsConnected}
		{
			call This.Connect
		}
	}
}