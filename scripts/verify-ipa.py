#!/usr/bin/env python3
"""Strict checks for this project's unsigned trial IPA, not an install guarantee."""
import argparse
import hashlib
import json
from pathlib import Path, PurePosixPath
import plistlib
import stat
import struct
import sys
import zipfile


def require(condition, message):
    if not condition:
        raise ValueError(message)


def verify(path, bundle_id, build_number):
    with zipfile.ZipFile(path) as archive:
        entries = archive.infolist()
        require(len(entries) <= 10000, 'Too many archive entries')
        require(sum(e.file_size for e in entries) <= 256 * 1024 * 1024, 'Expanded app exceeds validation limit')
        names = [e.filename for e in entries]
        require(len(names) == len(set(names)), 'Duplicate ZIP entries')
        prefix = 'Payload/MyNotes.app/'
        for entry in entries:
            name = entry.filename
            require(not PurePosixPath(name).is_absolute() and '..' not in PurePosixPath(name).parts and '\\' not in name, 'Unsafe ZIP path')
            require(name.startswith(prefix), 'Unexpected content outside app bundle')
            require(not stat.S_ISLNK(entry.external_attr >> 16), 'Symlinks are not supported')
            parts = [part.lower() for part in PurePosixPath(name).parts]
            require(not any(part in {'_codesignature', 'sc_info', 'embedded.mobileprovision', '.git'} for part in parts), 'Signing/provisioning metadata must not be packaged')
            require(not any(part.endswith(('.p12', '.p8', '.pem', '.key', '.mobileprovision', '.mobiledevicepairing')) or 'pairing' in part for part in parts), 'Private credentials or pairing data must not be packaged')
        require(archive.testzip() is None, 'ZIP checksum failure')
        info = plistlib.loads(archive.read(prefix + 'Info.plist'))
        require(info.get('CFBundleIdentifier') == bundle_id, 'Unexpected bundle identifier')
        require(info.get('CFBundleVersion') == str(build_number), 'Unexpected build number')
        require(info.get('CFBundlePackageType') == 'APPL', 'Not an application bundle')
        require(info.get('UIDeviceFamily') == [2], 'Package must target iPad only')
        require(info.get('CFBundleSupportedPlatforms') == ['iPhoneOS'], 'Not a device build')
        executable = info.get('CFBundleExecutable', '')
        require(executable and PurePosixPath(executable).name == executable, 'Invalid executable name')
        entry = archive.getinfo(prefix + executable)
        require(entry.external_attr >> 16 & 0o111, 'Executable permissions missing')
        binary = archive.read(entry)
        require(len(binary) >= 32, 'Truncated Mach-O header')
        magic, cpu, _, kind, count, size, _, _ = struct.unpack_from('<8I', binary)
        require(magic == 0xFEEDFACF and cpu == 0x0100000C and kind == 2, 'Expected arm64 Mach-O executable')
        require(32 + size <= len(binary), 'Truncated Mach-O commands')
        offset, platform = 32, None
        for _ in range(count):
            require(offset + 8 <= 32 + size, 'Invalid load command')
            command, length = struct.unpack_from('<2I', binary, offset)
            require(length >= 8 and offset + length <= 32 + size, 'Invalid load command length')
            require(command != 0x1D, 'Expected unsigned executable, found LC_CODE_SIGNATURE')
            if command == 0x32:
                require(length >= 24, 'Invalid build version command')
                platform = struct.unpack_from('<I', binary, offset + 8)[0]
            offset += length
        require(offset == 32 + size, 'Unexpected load command size')
        require(platform == 2, 'Expected iOS device platform, not Simulator/macOS')
        return {
            'status': 'unsigned-device-package-validated',
            'ipa_sha256': hashlib.sha256(Path(path).read_bytes()).hexdigest(),
            'bundle_id': bundle_id,
            'display_name': info.get('CFBundleDisplayName'),
            'build_number': str(build_number),
            'architecture': 'arm64',
            'device_family': [2],
            'minimum_os': info.get('MinimumOSVersion'),
            'files': len(entries),
            'sidestore_install': 'NOT RUN',
            'sidestore_refresh': 'NOT RUN',
            'data_preservation': 'NOT RUN',
        }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('ipa', type=Path)
    parser.add_argument('--bundle-id', required=True)
    parser.add_argument('--build-number', required=True)
    args = parser.parse_args()
    try:
        print(json.dumps(verify(args.ipa, args.bundle_id, args.build_number), indent=2))
    except (ValueError, KeyError, OSError, zipfile.BadZipFile, plistlib.InvalidFileException, struct.error) as error:
        print('IPA_VERIFY_FAIL: ' + str(error), file=sys.stderr)
        return 1
    return 0


if __name__ == '__main__':
    sys.exit(main())
