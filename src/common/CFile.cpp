//
// CFile.cpp
// Copyright Menace Software (www.menasoft.com).
//

#include "graycom.h"

#include <sys/types.h>
#include <sys/stat.h>
#ifdef _WIN32
#include <direct.h>	// _mkdir
#else
#include <errno.h>	// errno
#endif

bool CFile::SetFilePath( LPCTSTR pszName )
{
	ADDTOCALLSTACK("CFile::SetFilePath");
	if ( pszName == NULL )
		return false;
	if ( ! m_strFileName.CompareNoCase( pszName ))
		return( true );
	bool fIsOpen = ( m_hFile != NOFILE_HANDLE );
	if ( fIsOpen )
	{
		Close();
	}
	m_strFileName = pszName;
	if ( fIsOpen )
	{
		return( Open( NULL, OF_READ|OF_BINARY )); // GetMode()	// open it back up. (in same mode as before)
	}
	return( true );
}

LPCTSTR CFile::GetFileTitle() const
{
	ADDTOCALLSTACK("CFile::GetFileTitle");
	return( CGFile::GetFilesTitle( GetFilePath()));
}

//***************************************************************************
// -CGFile

int CGFile::GetLastError()	// static
{
#ifdef _WIN32
	return ::GetLastError();
#else
	return errno;
#endif
}

CGString CGFile::GetMergedFileName( LPCTSTR pszBase, LPCTSTR pszName ) // static
{
	ADDTOCALLSTACK("CGFile::GetMergedFileName");
	// Merge path and file name.

	TCHAR szFilePath[ _MAX_PATH ];
	if ( pszBase && pszBase[0] )
	{
		strcpy( szFilePath, pszBase );
		int len = strlen( szFilePath );
		if ( len && szFilePath[ len-1 ] != '\\' &&
			szFilePath[ len-1 ] != '/' )	// Might be LINUX
		{
			strcat( szFilePath, "\\" );
		}
	}
	else
	{
		szFilePath[0] = '\0';
	}
	if ( pszName )
	{
		strcat( szFilePath, pszName );
	}
	return static_cast<CGString>(szFilePath);
}

// No ADDTOCALLSTACK in these two: CLog uses them while opening the log.
bool CGFile::FileExists( LPCTSTR pszPath ) // static
{
	struct stat fileStat;
	return ( pszPath != NULL && stat( pszPath, &fileStat ) == 0 );
}

bool CGFile::MakeDirs( LPCTSTR pszDir ) // static
{
	if ( pszDir == NULL || pszDir[0] == '\0' )
		return true;	// the current directory

	TCHAR szPath[ _MAX_PATH ];
	strncpy( szPath, pszDir, sizeof(szPath) - 1 );
	szPath[ sizeof(szPath) - 1 ] = '\0';

	size_t len = strlen( szPath );
	while ( len > 1 && ( szPath[len-1] == '/' || szPath[len-1] == '\\' ))
		szPath[--len] = '\0';

	// Walk the path one component at a time, creating what is missing
	for ( size_t i = 1; i <= len; i++ )
	{
		if ( i < len && szPath[i] != '/' && szPath[i] != '\\' )
			continue;

		TCHAR ch = szPath[i];
		szPath[i] = '\0';
		if ( ! FileExists( szPath ))
		{
#ifdef _WIN32
			_mkdir( szPath );
#else
			mkdir( szPath, 0777 );
#endif
		}
		szPath[i] = ch;
	}
	return FileExists( szPath );
}

LPCTSTR CGFile::GetFilesTitle( LPCTSTR pszPath )	// static
{
	ADDTOCALLSTACK("CGFile::GetFilesTitle");
	// Just use COMMDLG.H GetFileTitle(LPCTSTR, LPTSTR, WORD) instead ?
	// strrchr
	size_t len = strlen(pszPath);
	while ( len > 0 )
	{
		len--;
		if ( pszPath[len] == '\\' || pszPath[len] == '/' )
		{
			len++;
			break;
		}
	}
	return( pszPath + len );
}

LPCTSTR CGFile::GetFilesExt( LPCTSTR pszName )	// static
{
	ADDTOCALLSTACK("CGFile::GetFilesExt");
	// get the EXTension including the .
	size_t lenall = strlen( pszName );
	size_t len = lenall;
	while ( len > 0 )
	{
		len--;
		if ( pszName[len] == '\\' || pszName[len] == '/' )
			break;
		if ( pszName[len] == '.' )
		{
			return( pszName + len );
		}
	}
	return( NULL );	// has no ext.
}

LPCTSTR CGFile::GetFileExt() const
{
	ADDTOCALLSTACK("CGFile::GetFileExt");
	// get the EXTension including the .
	return( GetFilesExt( GetFilePath()));
}


bool CGFile::OpenBase( void * pExtra )
{
	ADDTOCALLSTACK("CGFile::OpenBase");
	UNREFERENCED_PARAMETER(pExtra);

	return static_cast<CFile *>(this)->Open(GetFilePath(), GetMode());
}

void CGFile::CloseBase()
{
	ADDTOCALLSTACK("CGFile::CloseBase");
	CFile::Close();
}

bool CGFile::Open( LPCTSTR pszFilename, UINT uModeFlags, void FAR * pExtra )
{
	ADDTOCALLSTACK("CGFile::Open");
	// RETURN: true = success.
	// OF_BINARY | OF_WRITE
	if ( pszFilename == NULL )
	{
		if ( IsFileOpen())
			return( true );
	}
	else
	{
		Close();	// Make sure it's closed first.
	}

	if ( pszFilename == NULL )
		pszFilename = GetFilePath();
	else
		m_strFileName = pszFilename;

	if ( m_strFileName.IsEmpty())
		return( false );

	m_uMode = uModeFlags;
	if ( ! OpenBase( pExtra ))
		return( false );

	return( true );
}

void CGFile::Close()
{
	ADDTOCALLSTACK("CGFile::Close");
	if ( ! IsFileOpen())
		return;

	CloseBase();
	m_hFile = NOFILE_HANDLE;
}

//***************************************************************************
// -CFileText

LPCTSTR CFileText::GetModeStr() const
{
	ADDTOCALLSTACK("CFileText::GetModeStr");
	// end of line translation is crap. ftell and fseek don't work correctly when you use it.
	// fopen() args
	if ( IsBinaryMode())
		return ( IsWriteMode()) ? "wb" : "rb";
	if ( GetMode() & OF_READWRITE )
		return "a+b";
	if ( GetMode() & OF_CREATE )
		return "w";
	if ( IsWriteMode() )
		return "w";
	else
		return "rb";	// don't parse out the \n\r
}

void CFileText::CloseBase()
{
	ADDTOCALLSTACK("CFileText::CloseBase");
	if ( IsWriteMode())
	{
		fflush(m_pStream);
	}
	
	fclose(m_pStream);
	m_pStream = NULL;
}

bool CFileText::OpenBase( void FAR * pszExtra )
{
	ADDTOCALLSTACK("CFileText::OpenBase");
	UNREFERENCED_PARAMETER(pszExtra);

	// Open a file.
	m_pStream = fopen( GetFilePath(), GetModeStr());
	if ( m_pStream == NULL )
	{
		return( false );
	}
	// Get the low level handle for it.
	m_hFile = (OSFILE_TYPE)STDFUNC_FILENO(m_pStream);

	return( true );
}
