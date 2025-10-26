import os
import sys
import tempfile
import unittest
import pexpect

class InteractiveCLITests(unittest.TestCase):
    def setUp(self):
        self.tmpdir = tempfile.TemporaryDirectory()
        self.root = self.tmpdir.name
        self.script = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'update_inventory.py'))

    def tearDown(self):
        self.tmpdir.cleanup()

    def test_interactive_create_dryrun(self):
        inv_path = os.path.join(self.root, 'inventory.json')
        with open(inv_path, 'w', encoding='utf-8') as f:
            f.write('{}')
        cmd = sys.executable
        child = pexpect.spawn(cmd, [self.script, '--path', inv_path, '--dry-run'], timeout=5)
        child.expect('Artist:')
        child.sendline('Interactive Artist')
        child.expect('Title:')
        child.sendline('Interactive Title')
        child.expect('Media')
        child.sendline('')
        child.expect('Year')
        child.sendline('2025')
        child.expect('Serial number')
        child.sendline('')
        child.expect('Genre')
        child.sendline('jazz')
        child.expect('Auto-resolve serial conflicts')
        child.sendline('')
        child.expect('Merge')
        child.sendline('n')
        child.expect('Inventory path')
        child.sendline('')
        child.expect('Summary:')
        child.expect(r'Proceed to save\?')
        child.sendline('')
        child.expect(['Dry-run: will write output to', 'Saved'])
        child.expect(pexpect.EOF)
        output = child.before.decode('utf-8', errors='ignore')
        self.assertIn('Interactive Artist', output)
        self.assertIn('Interactive Title', output)

if __name__ == '__main__':
    unittest.main()
