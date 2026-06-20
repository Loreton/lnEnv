#!/usr/bin/env python3
#
# updated by ...: Loreto Notarantonio
# Date .........: 24-05-2026 15.41.49
#

import sys; sys.dont_write_bytecode = True
import os
def create_entry_point_main(project_info: dict, wrapper_path: Path):
    """Create __main__.py from the project's entry point"""

    # Get entry point from pyproject.toml
    entry_point = project_info.get("entry_point")
    package_name = project_info["package_name"]

    if entry_point:
        # Parse "package.module:function"
        if ":" in entry_point:
            module_path, function_name = entry_point.split(":")
        else:
            module_path = entry_point
            function_name = "main"

        # Convert to import path
        import_path = module_path.replace("/", ".")

        wrapper_content = f'''#!/usr/bin/env python3
"""Auto-generated __main__ for {project_info["project_name"]}

Entry point: {entry_point}
"""

import sys
import os

# Add current directory to path
sys.path.insert(0, os.path.dirname(__file__))

try:
    # Import the main function from the specified module
    module_path = "{import_path}"
    function_name = "{function_name}"

    # Dynamically import
    module = __import__(module_path, fromlist=[function_name])
    main_func = getattr(module, function_name)

except ImportError as e:
    print(f"ERROR: Could not import {{module_path}}")
    print(f"Details: {{e}}")
    print("\\nAvailable packages:")
    for item in os.listdir(os.path.dirname(__file__)):
        if item != "__pycache__" and not item.startswith("."):
            print(f"  - {{item}}")
    sys.exit(1)
except AttributeError as e:
    print(f"ERROR: Could not find function '{{function_name}}' in {{module_path}}")
    print(f"Details: {{e}}")
    sys.exit(1)

if __name__ == "__main__":
    sys.exit(main_func())
'''
    else:
        # Fallback: cerca main.py nel package
        wrapper_content = f'''#!/usr/bin/env python3
"""Auto-generated __main__ for {project_info["project_name"]}"""

import sys
import os

# Add current directory to path
sys.path.insert(0, os.path.dirname(__file__))

def find_main():
    """Cerca la funzione main nel package"""
    try:
        # Prova a importare dal package principale
        package_name = "{package_name}"
        main_module = __import__(f"{{package_name}}.main", fromlist=["main"])
        if hasattr(main_module, "main"):
            return main_module.main
    except ImportError:
        pass

    # Cerca in tutti i moduli
    for item in os.listdir(os.path.dirname(__file__)):
        if item.endswith(".py") and item != "__main__.py":
            module_name = item[:-3]
            try:
                module = __import__(module_name)
                if hasattr(module, "main"):
                    return module.main
            except ImportError:
                pass

    return None

if __name__ == "__main__":
    main_func = find_main()
    if main_func:
        sys.exit(main_func())
    else:
        print(f"ERROR: Could not find main function in {package_name}")
        sys.exit(1)
'''

    wrapper_path.write_text(wrapper_content)
    print(f">> Created entry point: {entry_point if entry_point else 'auto-detected'}")
