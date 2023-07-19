#pragma once

#include <memory>

#include "sc-memory/sc_addr.hpp"
#include "sc-memory/sc_memory.hpp"

namespace dialogControlModule
{
class AddMessageToTheDialogGenerator
{
public:
  explicit AddMessageToTheDialogGenerator(ScMemoryContext * ms_context);

  void addMessageToDialog(const ScAddr & dialogAddr, const ScAddr & messageAddr);

  std::unique_ptr<ScTemplate> createNotFirstMessageInDialogTemplate(
      const ScAddr & dialogAddr,
      const ScAddr & lastMessageAddr,
      const ScAddr & messageAddr);

  std::unique_ptr<ScTemplate> createFirstMessageInDialogTemplate(
      const ScAddr & dialogAddr,
      const ScAddr & messageAddr);

private:
  ScMemoryContext * context;
};

}  // namespace dialogControlModule