"""Offline negative tests for unsigned IPA validation; no device/account access."""
import importlib.util
from pathlib import Path
import plistlib
import struct
import tempfile
import unittest
import zipfile

SPEC = importlib.util.spec_from_file_location('ipa', Path(__file__).parents[1] / 'scripts/verify-ipa.py')
IPA = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(IPA)
BUNDLE = 'com.example.mynotes.sidestoretrial'
PREFIX = 'Payload/MyNotes.app/'


class IPATests(unittest.TestCase):
    def archive(self, folder, *, platform=2, signed=False, family=None, extra=None, bundle=BUNDLE, build='1'):
        commands = struct.pack('<6I', 0x32, 24, platform, 0, 0, 0)
        if signed:
            commands += struct.pack('<4I', 0x1D, 16, 0, 0)
        binary = struct.pack('<8I', 0xFEEDFACF, 0x0100000C, 0, 2, 2 if signed else 1, len(commands), 0, 0) + commands
        info = {'CFBundleIdentifier': bundle, 'CFBundleVersion': build, 'CFBundleExecutable': 'MyNotes',
                'CFBundlePackageType': 'APPL', 'UIDeviceFamily': family if family is not None else [2],
                'CFBundleSupportedPlatforms': ['iPhoneOS'], 'MinimumOSVersion': '17.0'}
        path = Path(folder) / 'test.ipa'
        with zipfile.ZipFile(path, 'w') as out:
            out.writestr(PREFIX + 'Info.plist', plistlib.dumps(info))
            executable = zipfile.ZipInfo(PREFIX + 'MyNotes')
            executable.external_attr = 0o100755 << 16
            out.writestr(executable, binary)
            if extra:
                out.writestr(extra, b'fixture only')
        return path

    def test_valid_unsigned_device_structure(self):
        with tempfile.TemporaryDirectory() as folder:
            result = IPA.verify(self.archive(folder), BUNDLE, '1')
            self.assertEqual(result['sidestore_install'], 'NOT RUN')
            self.assertEqual(result['architecture'], 'arm64')

    def test_rejects_simulator(self):
        with tempfile.TemporaryDirectory() as folder, self.assertRaisesRegex(ValueError, 'device platform'):
            IPA.verify(self.archive(folder, platform=7), BUNDLE, '1')

    def test_rejects_signed_executable(self):
        with tempfile.TemporaryDirectory() as folder, self.assertRaisesRegex(ValueError, 'LC_CODE_SIGNATURE'):
            IPA.verify(self.archive(folder, signed=True), BUNDLE, '1')

    def test_rejects_other_device_family(self):
        with tempfile.TemporaryDirectory() as folder, self.assertRaisesRegex(ValueError, 'iPad only'):
            IPA.verify(self.archive(folder, family=[1, 2]), BUNDLE, '1')

    def test_rejects_wrong_identity(self):
        with tempfile.TemporaryDirectory() as folder, self.assertRaisesRegex(ValueError, 'bundle identifier'):
            IPA.verify(self.archive(folder, bundle='com.example.other'), BUNDLE, '1')

    def test_rejects_wrong_version(self):
        with tempfile.TemporaryDirectory() as folder, self.assertRaisesRegex(ValueError, 'build number'):
            IPA.verify(self.archive(folder, build='2'), BUNDLE, '1')

    def test_rejects_private_metadata_and_unsafe_paths(self):
        for name in ['embedded.mobileprovision', 'device.mobiledevicepairing', 'signing.key', '_CodeSignature/CodeResources', '../escape']:
            with self.subTest(name=name), tempfile.TemporaryDirectory() as folder, self.assertRaises(ValueError):
                IPA.verify(self.archive(folder, extra=PREFIX + name), BUNDLE, '1')

    def test_rejects_extraneous_archive_content(self):
        with tempfile.TemporaryDirectory() as folder, self.assertRaisesRegex(ValueError, 'outside app'):
            IPA.verify(self.archive(folder, extra='notes/private.txt'), BUNDLE, '1')


if __name__ == '__main__':
    unittest.main()
