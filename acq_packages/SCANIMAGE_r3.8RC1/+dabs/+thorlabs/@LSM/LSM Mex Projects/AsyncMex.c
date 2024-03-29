/**
 * @file AsyncMex.h
 *
 * @brief Implementation of generic module for passing asynchronous events back onto the Matlab thread.
 *
 * @author Timothy O'Connor
 * @date 4/24/10
 *
 * <em><b>Copyright</b> - Northwestern University/Howard Hughes Medical Institute 2010</em>
 *
 */
//#ifndef ASYNCMEX_NOBUILDINFO
//	///@brief Visual Studio doesn't like generating BuildInfo.h, yet. Stay tuned...
//	#include "BuildInfo.h"
//#endif

///@brief Access to printf and sprint_f.
#include <stdio.h>
#define _AsyncMex_c
#include "AsyncMex.h"
#undef _AsyncMex_c


/*********************************
 *      MACRO DEFINITIONS        *
 *********************************/
///@brief Use printf semantics to display a message to the console.
#define AsyncMex_printMsg(...) printf(__VA_ARGS__)
///@brief Use printf semantics to display an error message to the console.
#define AsyncMex_errorMsg(...) printf(__VA_ARGS__)
#ifdef ASYNCMEX_DEBUG
   #pragma message("ASYNCMEX_DEBUG - Compiling in debug mode.")
   ///@brief Use printf semantics to display a debugging message to the console, if debugging is enabled at compile time.
   #define AsyncMex_DebugMsg(...) printf(__VA_ARGS__)
#else
   ///@brief Use printf semantics to display a debugging message to the console, if debugging is enabled at compile time.
   #define AsyncMex_DebugMsg(...)
#endif

/*********************************
 *           INCLUDES            *
 *********************************/
//#include "AsyncMex.h"

void AsyncMex_printWindowsErrorMessage(int lineNum)
{
   DWORD lastError;
   LPTSTR errorMsg = NULL;

   lastError = GetLastError();
   //FormatMessage(dwFlags, lpSource, dwMessageId, dwLanguageId, lpBuffer, nSize, Arguments)
   if (!FormatMessage(FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM |
        FORMAT_MESSAGE_IGNORE_INSERTS, NULL, lastError, (DWORD)0x00, (LPTSTR)&errorMsg, 1024, NULL))
   {
      AsyncMex_errorMsg("printWindowsErrorMessage() - Failed to format message for error: %d\n"
                   "                             FormatMessage Error: %d\n", lastError, GetLastError());
      return;
   }

   AsyncMex_errorMsg("AsyncMex (@ %d) - Windows Error: %d\n"
                "                          %s\n", lineNum, lastError, errorMsg);
   LocalFree(errorMsg);

   return;
}

int AsyncMex_structToString(AsyncMex* asyncM, char* buff, size_t buffSize, const char* prefix)
{
   return sprintf_s(buff, buffSize,
                    "%sAsyncMex (@%p) - \n"
                    "%s   matlabThread: @%p\n"
                    "%s   matlabThreadID: %u\n"
                    "%s   messageID: %u\n"
                    "%s   userData: @%p\n"
                    "%s   callback: @%p\n"
                    "%s   hwnd: %p\n"
                    "%s   wndClass: @%p\n",
                    prefix, asyncM,
                    prefix, asyncM->matlabThread,
                    prefix, asyncM->matlabThreadID,
                    prefix, asyncM->messageID,
                    prefix, asyncM->userData,
                    prefix, &(asyncM->callback),
                    prefix, asyncM->hwnd,
                    prefix, &(asyncM->wndClass));
}

/**
 * @brief Registers a hook function for handling a <tt>AsyncMex</tt> object.
 * This should be called from within the Matlab thread.
 * @arg <tt>asyncM</tt> - The <tt>AsyncMex</tt> to be registered with a hook function.
 * @return 0 if successful, non-zero otherwise.
 */
LRESULT CALLBACK AsyncMex_CallbackMessagePumpHook(int code, WPARAM wParam, LPARAM lParam)
{
  LRESULT result;
  MSG* msg = (MSG *)lParam;

  AsyncMex_DebugMsg("AsyncMex_CallbackMessagePumpHook(%d, %p, %p)\n", code, wParam, lParam);
  if (code == HC_ACTION)
  {
    if ((wParam != PM_NOREMOVE))
    {
		AsyncMex_DebugMsg("AsyncMex_CallbackMessagePumpHook:\n\tmsg->message: %u"
			              "\n\tmsg->wParam: @%p"
						  "\n\tmsg->lParam: @%p"
						  "\n\tmsg->hwnd: %u\n", 
						  msg->message, msg->wParam, msg->lParam, msg->hwnd);

		AsyncMex_DebugMsg("ID of expected message: %u\n",ASYNCMEX_WINDOWMESSAGE_ID);
      //Dispatch the event here.
      if (msg->message == ASYNCMEX_WINDOWMESSAGE_ID)
      {

        AsyncMex_DebugMsg("AsyncMex_CallbackMessagePumpHook: Invoking user-level callback, in Matlab thread...\n");
        ((AsyncMex*)(msg->wParam))->callback(msg->lParam, ((AsyncMex*)(msg->wParam))->userData);
        return 0;
      }
      else
        result = CallNextHookEx(NULL, code, wParam, lParam);//This is a peek operation, let it slide.
    }
  }
  else
    result = CallNextHookEx(NULL, code, wParam, lParam);

  return result;
}

/**
 * @brief Registers a hook function for handling a <tt>AsyncMex</tt> object.
 * This should be called from within the Matlab thread.
 * @arg <tt>asyncM</tt> - The <tt>AsyncMex</tt> to be registered with a hook function.
 * @return 0 if successful, non-zero otherwise.
 */
int AsyncMex_registerHookFcn(AsyncMex* asyncM)
{
  AsyncMex_DebugMsg("AsyncMex_registerHookFcn(@%p)\n", asyncM);
  if (ASYNCMEX_MESSAGE_PUMP_HOOK_ID == NULL)
      ASYNCMEX_MESSAGE_PUMP_HOOK_ID = SetWindowsHookEx(WH_GETMESSAGE, AsyncMex_CallbackMessagePumpHook, NULL, GetCurrentThreadId());
  
  if (ASYNCMEX_MESSAGE_PUMP_HOOK_ID == NULL)
      return -1;

  asyncM->messagePumpHookID = ASYNCMEX_MESSAGE_PUMP_HOOK_ID;
  AsyncMex_DebugMsg("AsyncMex_registerHookFcn(@%p) - messagePumpHookID: %u\n", asyncM, asyncM->messagePumpHookID);

  return 0;
}

/**
 * @brief Initialization function for a <tt>AsyncMex</tt> object.
 * This will capture information about the current thread (which should be the Matlab thread, 
 * since this is only to be called from a Mex function). It also initalized the message identifier.
 * Lastly, it registers the actual hook function.
 * @arg <tt>asyncM</tt> - The <tt>AsyncMex</tt> to be initialized.
 * @return 0 if successful, non-zero otherwise.
 */
int AsyncMex_intialize(AsyncMex* asyncM)
{
  AsyncMex_DebugMsg("AsyncMex_intialize(@%p)\n", asyncM);
  //Thread.
  AsyncMex_DebugMsg("AsyncMex_intialize: Collecting thread information...\n");
  if (!DuplicateHandle(GetCurrentProcess(), GetCurrentThread(), GetCurrentProcess(),
       &asyncM->matlabThread, 0, FALSE, DUPLICATE_SAME_ACCESS))
  {
    AsyncMex_printWindowsErrorMessage(__LINE__);
    return -1;
  }
  asyncM->matlabThreadID = GetCurrentThreadId();

  //Install message pump hook, to handle processing of NIMEX messages into the Matlab thread.
  //Do the install when the first callback is registered, otherwise leave it as NULL.
  //The hook will remain installed until NIMEX is freed.
  asyncM->messagePumpHookID = NULL;//SetWindowsHookEx(WH_GETMESSAGE, (HOOKPROC)<INSERT_FUNCTION_POINTER_HERE>, NULL, GetCurrentThreadId());

  AsyncMex_DebugMsg("AsyncMex_intialize: Requesting globally unique message ID for \"%s\"\n", ASYNCMEX_WINDOWMESSAGE_NAME);
  if (ASYNCMEX_WINDOWMESSAGE_ID == 0)
    ASYNCMEX_WINDOWMESSAGE_ID = RegisterWindowMessage(ASYNCMEX_WINDOWMESSAGE_NAME);

  if (!ASYNCMEX_WINDOWMESSAGE_ID)
  {
    AsyncMex_printWindowsErrorMessage(__LINE__);
    return -2;
  }
  AsyncMex_DebugMsg("AsyncMex_intialize - Got globally unique message ID: \"%s\"->%u\n", ASYNCMEX_WINDOWMESSAGE_NAME, ASYNCMEX_WINDOWMESSAGE_ID);

  if (AsyncMex_registerHookFcn(asyncM))
    return -3;

  return 0;
}

int AsyncMex_postEventMessage(AsyncMex* asyncM, LPARAM lParam)
{
  AsyncMex_DebugMsg("AsyncMex_postEventMessage(@%p, %p)\n", asyncM, lParam);
  if (asyncM->matlabThreadID == 0)
    return -1;

  PostThreadMessage(asyncM->matlabThreadID, ASYNCMEX_WINDOWMESSAGE_ID, (WPARAM)asyncM, lParam);
  
  return 0;
}

/**
 * @brief Returns the handle to the active module (DLL or executable), necessary for working with windows.
 * @return The current module's handle.
 */
/*HINSTANCE AsyncMex_getCurrentModuleHandle(void)
{
    #ifdef MATLAB_MEX_FILE
       return GetModuleHandle("AsyncMex.mexw32");
    #else
       return GetModuleHandle("AsyncMex.dll");
    #endif
}

LRESULT CALLBACK AsyncMex_WindowProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam)
{
}

int AsyncMex_createClientWindow(AsyncMex* asyncM, WINDOWPROC windowProc)
{
   HINSTANCE moduleHandle = NULL;
   ATOM wndClassAtom = NULL;

   moduleHandle = AsyncMex_getCurrentModuleHandle();
   if (moduleHandle == NULL)
   {
      printWindowsErrorMessage();
      MCT_errorMsg("MCT_createClientWindow() - Failed to get module handle.\n");
      return -1;
   }

   if (asyncM->hwnd == NULL)
   {
      asyncM->wndClass.cbSize = sizeof(WNDCLASSEX);
      asyncM->wndClass.style = CS_GLOBALCLASS;
      asyncM->wndClass.lpfnWndProc = AsyncMex_WindowProc;
      asyncM->_wndClass.cbClsExtra = 0;
      asyncM->wndClass.cbWndExtra = 0;
      asyncM->wndClass.hInstance = moduleHandle;
      asyncM->wndClass.hIcon = NULL;
      asyncM->wndClass.hCursor = NULL;
      asyncM->wndClass.hbrBackground = NULL;
      asyncM->wndClass.lpszMenuName = NULL;
      asyncM->wndClass.lpszClassName = ASYNCMEX_WINDOWCLASS_NAME;
      asyncM->wndClass.hIconSm = NULL;

      wndClassAtom = RegisterClassEx(&asyncM->wndClass);
      if (!wndClassAtom)
      {
         printWindowsErrorMessage(__LINE__);
         AsyncMex_errorMsg("AsyncMex_createClientWindow() - Failed to create register window class.\n");
         return -2;
      }

      AsyncMex_debugMsg("AsyncMex_createClientWindow() - Creating window...\n");

      //Use a full-fledged window (WS_OVERLAPPED), so we can recieve broadcast messages.
      asyncM->hwnd = CreateWindow(ASYNCMEX_WINDOWCLASS_NAME, "MCT_Message_Only", WS_OVERLAPPEDWINDOW, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT,
                                   CW_USEDEFAULT, WS_OVERLAPPED, (HMENU)NULL, moduleHandle, (LPVOID)NULL);

      AsyncMex_debugMsg("AsyncMex_createClientWindow() - Created window: %p\n", asyncM->hwnd);
      if (MCT_hwnd == NULL)
      {
         printWindowsErrorMessage(__LINE__);
         AsyncMex_errorMsg("AsyncMex_createClientWindow() - Failed to create messaging client window.\n");
         return -3;
      }

      ShowWindow(MCT_hwnd, SW_HIDE);
   }

   AsyncMex_debugMsg("AsyncMex_createClientWindow() - Window has been created.\n");

   return 0;
}

int AsyncMex_destroyClientWindow(AsyncMex* asyncM)
{
   HINSTANCE moduleHandle = NULL;
   BOOL result;

   MCT_debugMsg("AsyncMex_destroyClientWindow() - Destroying client window...\n");

   if (!DestroyWindow(MCT_hwnd))
   {
      printWindowsErrorMessage(__LINE__);
      AsyncMex_errorMsg("AsyncMex_destroyClientWindow() - Failed to destroy window.\n");
      result = -1;
   }

   moduleHandle = AsyncMex_getCurrentModuleHandle();
   if (moduleHandle == NULL)
   {
      printWindowsErrorMessage(__LINE__);
      AsyncMex_errorMsg("AsyncMex_destroyClientWindow() - Failed to get module handle.\n");
      return -2;
   }

   if (!UnregisterClass(ASYNCMEX_WINDOWCLASS_NAME, moduleHandle))
   {
      printWindowsErrorMessage(__LINE__);
      AsyncMex_errorMsg("AsyncMex_destroyClientWindow() - Failed to get unregister window class.\n");
      result = -3;
   }

   return result;
}*/

AsyncMex* AsyncMex_create(AsyncMex_Callback* callback, void* userData)
{
  AsyncMex* asyncM;
  int status;
  
  AsyncMex_DebugMsg("AsyncMex_create(@%p, @%p)\n", callback, userData);
  asyncM = (AsyncMex *)calloc(1, sizeof(AsyncMex));
  if (asyncM == NULL)
    return NULL;
  
  asyncM->callback = callback;
  asyncM->userData = userData;

  if (status = AsyncMex_intialize(asyncM))
  {
    AsyncMex_errorMsg("Failed to initialize AsyncMex object (@%p): %d", asyncM, status);
    AsyncMex_destroy(&asyncM);
    return NULL;
  }
  //if (status = AsyncMex_registerHookFcn(asyncM))
  //{
  //  AsyncMex_errorMsg("Failed to register Hook Function (@%p): %d", asyncM, status);
  //  AsyncMex_destroy(&asyncM);
  //  return NULL;
  //}
  
  return asyncM;
}

void AsyncMex_destroy(AsyncMex** asyncM)
{
  if (*asyncM == NULL)
  {
    AsyncMex_DebugMsg("AsyncMex_destroy(@%p->NULL)\n", asyncM);
    return;
  }
  AsyncMex_DebugMsg("AsyncMex_destroy(@%p->@%p)\n", asyncM, *asyncM);

  if ((*asyncM)->messagePumpHookID != 0)
    UnhookWindowsHookEx((*asyncM)->messagePumpHookID);
  
  //if ((*asyncM)->hwnd != NULL)
  //  AsyncMex_destroyClientWindow

  free(*asyncM);
  *asyncM = NULL;
  
  return;
}
