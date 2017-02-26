struct user32DLL_lib
(
	fn DisableWindowsGhostingClass =
	(
		out = undefined
		if classof (dotnet.GetType "DisableWindowsGhosting") != dotNetObject then
		(
			 source = StringStream ("
			using System.Runtime.InteropServices;

			public class DisableWindowsGhosting
			{
			[DllImport(\"user32.dll\")]
			public static extern bool DisableProcessWindowsGhosting();
			}")

			compilerParams = dotnetobject "System.CodeDom.Compiler.CompilerParameters"
			compilerParams.ReferencedAssemblies.Add("System.dll");
			compilerParams.GenerateInMemory = on
			csharpProvider = dotnetobject "Microsoft.CSharp.CSharpCodeProvider"
			compilerResults = csharpProvider.CompileAssemblyFromSource compilerParams #(source as String)
			flush source
			close source
			if (compilerResults.Errors.Count > 0 ) then
			(
				local errs = stringstream ""
				for i = 0 to (compilerResults.Errors.Count-1) do
				(
					err = compilerResults.Errors.Item[i]
					format "Error:% Line:% Column:% %\n" err.ErrorNumber err.Line err.Column err.ErrorText to:errs
				)
				format "%\n" errs
				return False
			)
			else
			(
				out = compilerResults.CompiledAssembly.CreateInstance "DisableWindowsGhosting"
			)
		)else(out = dotnetobject "DisableWindowsGhosting")
		out.DisableProcessWindowsGhosting()
		True
	),
	
	fn getViewPortAssembly =
	(
		source = "using System;\n"
		source += "using System.Runtime.InteropServices;\n"
		source += "using System.Text;\n"
		source += "class assembly\n"
		source += "{\n"
		source += " [DllImport(\"user32.dll\")]\n"
		source += " public static extern bool SetWindowPos(IntPtr hWnd, int hWndArg, int Left, int Top, int Width, int Height, int hWndFlags);\n"
		source += " [DllImport(\"user32.dll\")]\n"
		source += " static extern bool GetWindowRect(IntPtr hWnd, out RECT rect);\n"
		source += " public struct RECT\n"
		source += " {\n"
		source += " public int Left;\n"
		source += " public int Top;\n"
		source += " public int Right;\n"
		source += " public int Bottom;\n"
		source += " }\n"
		source += " public int[] getWindowRect(IntPtr hWnd)\n"
		source += " {\n"
		source += " RECT rect;\n"
		source += " if ( GetWindowRect(hWnd, out rect) )\n"
		source += " {\n"
		source += " return new int[] { rect.Left, rect.Top, rect.Right - rect.Left, rect.Bottom - rect.Top };\n"
		source += " }\n"
		source += " return null;\n"
		source += " }\n"
		source += "}\n"

		csharpProvider = dotnetobject "Microsoft.CSharp.CSharpCodeProvider"
		compilerParams = dotnetobject "System.CodeDom.Compiler.CompilerParameters"

		compilerParams.GenerateInMemory = on
		compilerResults = csharpProvider.CompileAssemblyFromSource compilerParams #(source)
		assembly = compilerResults.CompiledAssembly.createInstance "assembly"
		assembly
	),
	fn null =
	(
		undefined
	),
	fn _init =
	(
		DisableWindowsGhostingClass()
		--getViewPortAssembly()
	),
	init = _init()
)
_user32DLL = user32DLL_lib()