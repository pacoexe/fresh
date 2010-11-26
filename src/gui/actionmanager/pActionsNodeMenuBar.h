#ifndef PACTIONSNODEMENUBAR_H
#define PACTIONSNODEMENUBAR_H

#include "core/FreshExport.h"
#include "pActionsNode.h"

#include <QMenuBar>

class pActionsNodeModel;

class FRESH_EXPORT pActionsNodeMenuBar : public QMenuBar
{
	Q_OBJECT
	
public:
	pActionsNodeMenuBar( QWidget* parent = 0 );
	~pActionsNodeMenuBar();
	
	void setModel( pActionsNodeModel* model );
	pActionsNodeModel* model() const;
	
	bool addAction( const QString& path, QAction* action );
	QAction* addAction( const QString& path, const QString& text, const QIcon& icon = QIcon() );
	pActionsNode addMenu( const QString& path );
	
	bool removeAction( const QString& path );
	bool removeAction( QAction* action );
	bool removeMenu( const QString& path );
	
	QMenu* menu( const QString& path ) const;
	QString menuPath( QMenu* menu ) const;
	
	QAction* action( const QString& path ) const;
	QString actionPath( QAction* action ) const;
	
protected:
	pActionsNodeModel* mModel;
	QHash<QString, QMenu*> mMenus;
	
	void recursiveSync( const pActionsNode& node );
	void sync();

protected slots:
	void model_nodeInserted( const pActionsNode& node );
	void model_nodeChanged( const pActionsNode& node );
	void model_nodeRemoved( const pActionsNode& node );
	void model_nodesCleared();
};

#endif // PACTIONSNODEMENUBAR_H